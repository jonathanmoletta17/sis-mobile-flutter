class AttachmentDisplay {
  static const _imageExtensions = <String>{
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.heic',
    '.heif',
    '.avif',
  };

  static bool isImageDocument({required String filename, String? mime}) {
    final normalizedMime = (mime ?? '').trim().toLowerCase();
    if (normalizedMime.startsWith('image/')) return true;

    final normalizedName = filename.trim().toLowerCase();
    return _imageExtensions.any(normalizedName.endsWith);
  }
}
