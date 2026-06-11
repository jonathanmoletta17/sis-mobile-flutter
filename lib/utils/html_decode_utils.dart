// lib/utils/html_decode_utils.dart
class HtmlDecodeUtils {
  static String decodeHtmlEntitiesAndClean(String htmlText) {
    String decoded = htmlText
        .replaceAll('&amp;', '&')
        .replaceAll('&#62;', '>')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&quot;', '"')
        .replaceAll('(estrutura de árvore)', '') // Remove o texto indesejado
        .trim();
    return decoded;
  }
}
