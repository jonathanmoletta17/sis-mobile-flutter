class AttachmentOpeningPolicy {
  static const _octetStream = 'application/octet-stream';

  static String safeFilename(String filename) {
    final sanitized = filename.trim().replaceAll(RegExp(r'[\\/]'), '_');
    return sanitized.isEmpty ? 'anexo' : sanitized;
  }

  static String resolveMimeType({
    required String filename,
    String? mimeType,
  }) {
    final normalizedMime = mimeType?.trim().toLowerCase();
    if (normalizedMime != null &&
        normalizedMime.isNotEmpty &&
        normalizedMime != _octetStream) {
      return normalizedMime;
    }

    return _guessMimeFromFilename(filename) ?? normalizedMime ?? _octetStream;
  }

  static bool shouldOpenInlineInBrowser({
    required String filename,
    String? mimeType,
  }) {
    final mime = resolveMimeType(filename: filename, mimeType: mimeType);
    return mime.startsWith('image/') ||
        mime.startsWith('video/') ||
        mime == 'application/pdf' ||
        mime.startsWith('text/') ||
        mime == 'application/json' ||
        mime == 'application/xml' ||
        mime == 'text/csv';
  }

  static String? _guessMimeFromFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.csv')) return 'text/csv';
    if (lower.endsWith('.json')) return 'application/json';
    if (lower.endsWith('.xml')) return 'application/xml';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.avi')) return 'video/x-msvideo';
    if (lower.endsWith('.webm')) return 'video/webm';
    return null;
  }
}
