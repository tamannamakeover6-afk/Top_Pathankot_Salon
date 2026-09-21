import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tamanna/data/models/cloudinary_asset.dart';

enum CloudinaryPreset { thumb, card, detail, banner, avatar }

class CloudinaryService {
  static const String cloudName = 'juulrv7s';
  static const String uploadPreset = 'tamanna_uploads';

  static Future<CloudinaryAsset> uploadBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return CloudinaryAsset(
      url: data['secure_url']?.toString() ?? '',
      publicId: data['public_id']?.toString() ?? '',
    );
  }

  static String transform(
    String url, {
    CloudinaryPreset preset = CloudinaryPreset.card,
    int? width,
  }) {
    if (url.isEmpty) return url;
    if (!url.contains('res.cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }
    final w = width ?? _widthFor(preset);
    final crop = preset == CloudinaryPreset.banner ? 'fill' : 'fill';
    final transformation = 'f_auto,q_auto,c_$crop,g_auto,w_$w';
    if (url.contains('/upload/f_auto') || url.contains('/upload/w_')) {
      return url;
    }
    return url.replaceFirst('/upload/', '/upload/$transformation/');
  }

  static int _widthFor(CloudinaryPreset preset) {
    switch (preset) {
      case CloudinaryPreset.thumb:
        return 240;
      case CloudinaryPreset.card:
        return 720;
      case CloudinaryPreset.detail:
        return 1400;
      case CloudinaryPreset.banner:
        return 1800;
      case CloudinaryPreset.avatar:
        return 160;
    }
  }
}
