class DticText {
  const DticText._();

  static String cleanPlainText(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = decodeEntities(value.toString()).trim();
    if (text.isEmpty) return fallback;
    return text.replaceAll(RegExp(r'[ \t]+'), ' ');
  }

  static String stripHtml(dynamic value, {String fallback = ''}) {
    final decoded = decodeEntities(value?.toString() ?? '');
    if (decoded.trim().isEmpty) return fallback;

    final withLineBreaks = decoded
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    final stripped = decodeEntities(
      withLineBreaks.replaceAll(RegExp(r'<[^>]+>'), ''),
    );

    final lines = stripped
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trim().replaceAll(RegExp(r'[ \t]+'), ' '))
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return fallback;
    return lines.join('\n');
  }

  static String decodeEntities(String input) {
    var decoded = input
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final codePoint = int.tryParse(match.group(1) ?? '');
      return codePoint == null
          ? (match.group(0) ?? '')
          : String.fromCharCode(codePoint);
    });

    decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final codePoint = int.tryParse(match.group(1) ?? '', radix: 16);
      return codePoint == null
          ? (match.group(0) ?? '')
          : String.fromCharCode(codePoint);
    });

    return decoded;
  }
}
