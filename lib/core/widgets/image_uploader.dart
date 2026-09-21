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

  Future<void> _pick() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) {
        setState(() => loading = false);
        return;
      }
      final file = files.first;
      final bytes = await file.readAsBytes();
      final size = await file.length() ?? bytes.lengthInBytes;
      if (size > 8 * 1024 * 1024) {
        throw Exception('Cloudinary: image must be under 8 MB.');
      }
      final asset = await CloudinaryService.uploadBytes(
        bytes,
        filename: file.name,
      );
      widget.onUploaded(asset);
    } catch (e) {
      setState(() => error = ErrorHandler.message(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: loading ? null : _pick,
          child: widget.url.isEmpty
              ? Container(
                  height: 140,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Upload image'),
                )
              : Stack(
                  children: [
                    CloudinaryImage(url: widget.url, height: 140, width: double.infinity),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton.filled(
                        onPressed: widget.onCleared,
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error!, style: const TextStyle(color: AppColors.danger)),
          ),
      ],
    );
  }
}
