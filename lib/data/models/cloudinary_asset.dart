class CloudinaryAsset {
  final String url;
  final String publicId;

  const CloudinaryAsset({required this.url, this.publicId = ''});

  Map<String, dynamic> toMap() => {'url': url, 'publicId': publicId};

  factory CloudinaryAsset.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CloudinaryAsset(url: '');
    return CloudinaryAsset(
      url: map['url']?.toString() ?? map['imageUrl']?.toString() ?? '',
      publicId: map['publicId']?.toString() ?? map['imagePublicId']?.toString() ?? '',
    );
  }
}
