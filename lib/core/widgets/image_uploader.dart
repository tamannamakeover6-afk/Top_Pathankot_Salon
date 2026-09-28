import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/data/models/cloudinary_asset.dart';
import 'package:tamanna/data/services/cloudinary_service.dart';

class ImageUploader extends StatefulWidget {
  final String url;
  final ValueChanged<CloudinaryAsset> onUploaded;
  final VoidCallback? onCleared;

  const ImageUploader({
    super.key,
    required this.url,
    required this.onUploaded,
    this.onCleared,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  bool loading = false;
  String? error;
  Uint8List? localBytes;
  String? currentUrl;
  String? uploadedFileName;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
  }

  @override
  void didUpdateWidget(covariant ImageUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      setState(() {
        currentUrl = widget.url;
        if (widget.url.isEmpty) {
          localBytes = null;
          uploadedFileName = null;
        }
      });
    }
  }

  Future<void> _pick() async {
    setState(() {
      error = null;
    });
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();
      final size = await file.length() ?? bytes.lengthInBytes;
      if (bytes.isEmpty) throw Exception('Selected file is empty.');

      if (size > 8 * 1024 * 1024) {
        throw Exception('Image size must be under 8 MB.');
      }

      setState(() {
        localBytes = bytes;
        uploadedFileName = file.name;
        loading = true;
      });

      final asset = await CloudinaryService.uploadBytes(
        bytes,
        filename: file.name,
      );

      if (mounted) {
        setState(() {
          currentUrl = asset.url;
          loading = false;
        });
      }
      widget.onUploaded(asset);
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = ErrorHandler.message(e);
        });
      }
    }
  }

  void _clear() {
    setState(() {
      localBytes = null;
      currentUrl = '';
      uploadedFileName = null;
      error = null;
    });
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (localBytes != null) || (currentUrl != null && currentUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasImage ? AppColors.success.withValues(alpha: 0.5) : AppColors.border,
              width: hasImage ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. If has image: show preview
              if (hasImage) ...[
                if (localBytes != null)
                  Image.memory(
                    localBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                else if (currentUrl != null && currentUrl!.isNotEmpty)
                  CloudinaryImage(
                    url: currentUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
              ] else ...[
                // Empty state: clickable upload prompt
                InkWell(
                  onTap: loading ? null : _pick,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: AppColors.rose,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Click to upload photo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'JPG, PNG or WEBP up to 8MB',
                          style: TextStyle(fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 2. Loading overlay while uploading
              if (loading)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      SizedBox(height: 12),
                      Text(
                        'Uploading photo...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Top status badge & action buttons when image is present
              if (hasImage && !loading) ...[
                // Top-left success badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.greenAccent),
                        SizedBox(width: 5),
                        Text(
                          'Uploaded ✓',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Top-right actions (Change / Delete)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Change photo',
                        child: InkWell(
                          onTap: _pick,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.edit, size: 14, color: AppColors.textPrimary),
                                SizedBox(width: 4),
                                Text(
                                  'Change',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Remove photo',
                        child: InkWell(
                          onTap: _clear,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom helper note
        if (hasImage && !loading)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    uploadedFileName != null
                        ? 'Ready to save: $uploadedFileName'
                        : 'Photo ready! You can now click Save below.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    error!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
