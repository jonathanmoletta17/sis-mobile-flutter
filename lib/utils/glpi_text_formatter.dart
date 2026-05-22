import 'package:html/parser.dart' as html_parser;

/// Normalização centralizada de texto vindo do GLPI.
///
/// O GLPI pode retornar campos ricos como HTML real, HTML escapado
/// (&lt;div&gt;) e entidades duplamente escapadas (&amp;ccedil;). A UI mobile
/// deve receber texto humano, nunca tags ou entidades cruas.
class GlpiTextFormatter {
  static final RegExp _htmlTagPattern = RegExp(r'<[^>]+>');
  static final RegExp _whitespacePattern = RegExp(r'[ \t\f\v]+');
  static final RegExp _multiLinePattern = RegExp(r'\n{3,}');

  static String toPlainText(dynamic value, {bool preserveLineBreaks = false}) {
    if (value == null) return '';
    final raw = value.toString();
    if (raw.trim().isEmpty) return '';

    var prepared = _decodeAmpEscapedEntities(raw);
    prepared = _prepareBlockBreaks(prepared);

    try {
      final fragment = html_parser.parseFragment(prepared);
      fragment
          .querySelectorAll('script, style')
          .forEach((node) => node.remove());
      final parsedText = fragment.text ?? '';
      return _normalizeWhitespace(
        _decodeAmpEscapedEntities(parsedText),
        preserveLineBreaks: preserveLineBreaks,
      );
    } catch (_) {
      final withoutTags = prepared.replaceAll(_htmlTagPattern, ' ');
      return _normalizeWhitespace(
        _decodeAmpEscapedEntities(withoutTags),
        preserveLineBreaks: preserveLineBreaks,
      );
    }
  }

  static String _prepareBlockBreaks(String value) {
    return value
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\s*/\s*p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\s*/\s*div\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\s*/\s*li\s*>', caseSensitive: false), '\n');
  }

  static String _decodeAmpEscapedEntities(String value) {
    // Duas passagens resolvem casos comuns do GLPI/FormCreator:
    // &amp;ccedil; -> &ccedil; -> ç via parser HTML.
    var decoded = value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

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

  static String _normalizeWhitespace(
    String value, {
    required bool preserveLineBreaks,
  }) {
    if (preserveLineBreaks) {
      return value
          .split('\n')
          .map((line) => line.replaceAll(_whitespacePattern, ' ').trim())
          .where((line) => line.isNotEmpty)
          .join('\n')
          .replaceAll(_multiLinePattern, '\n\n')
          .trim();
    }

    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
