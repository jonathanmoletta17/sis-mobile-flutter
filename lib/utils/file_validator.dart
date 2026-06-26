import 'dart:io';

class FileValidator {
  // 100 MB (Ajuste conforme a configuração do seu PHP/GLPI 'upload_max_filesize')
  // Aumentado para acomodar vídeos; verifique upload_max_filesize no GLPI
  static const int maxSizeInBytes = 100 * 1024 * 1024;

  static const List<String> allowedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', // Imagens
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv', // Documentos
    'mp4', 'mov', 'avi', 'webm', // Vídeos
  ];

  static String? validate(File file) {
    // 1. Validar Tamanho
    final int size = file.lengthSync();
    if (size > maxSizeInBytes) {
      final mb = (maxSizeInBytes / 1024 / 1024).toStringAsFixed(0);
      return 'O arquivo excede o limite de ${mb}MB.';
    }

    // 2. Validar Extensão
    final String path = file.path.toLowerCase();
    bool hasValidExtension = false;
    for (final ext in allowedExtensions) {
      if (path.endsWith('.$ext')) {
        hasValidExtension = true;
        break;
      }
    }

    if (!hasValidExtension) {
      return 'Tipo de arquivo não permitido.';
    }

    return null; // Válido
  }

  /// Verifica se o arquivo é uma imagem
  static bool isImage(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }

  /// Obtém um ícone emoji apropriado para o tipo de arquivo
  static String getFileIcon(String fileName) {
    final ext = fileName.toLowerCase();
    if (isImage(fileName)) return '🖼️';
    if (ext.endsWith('.pdf')) return '📄';
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return '📝';
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return '📊';
    if (ext.endsWith('.txt') || ext.endsWith('.csv')) return '📋';
    if (ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.avi') ||
        ext.endsWith('.webm')) {
      return '🎬';
    }
    return '📎';
  }
}
