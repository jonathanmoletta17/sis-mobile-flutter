import 'glpi_text_formatter.dart';

class TicketFormSummaryField {
  const TicketFormSummaryField({required this.label, required this.value});

  final String label;
  final String value;
}

class TicketFormSummary {
  const TicketFormSummary({required this.description, required this.fields});

  final String description;
  final List<TicketFormSummaryField> fields;

  bool get isEmpty => description.trim().isEmpty && fields.isEmpty;

  static TicketFormSummary parse(String rawValue) {
    final decoded = GlpiTextFormatter.toPlainText(
      rawValue,
      preserveLineBreaks: true,
    ).replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = decoded
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final descriptionLines = <String>[];
    final fields = <TicketFormSummaryField>[];
    var inAppForm = false;

    for (final line in lines) {
      final normalized = _normalize(line);
      if (normalized.contains('formulario do app')) {
        inAppForm = true;
        continue;
      }
      if (_isSeparator(line)) {
        continue;
      }

      if (!inAppForm) {
        descriptionLines.add(line);
        continue;
      }

      final cleanedLine = line.replaceFirst(RegExp(r'^[•*-]\s*'), '').trim();
      final separator = cleanedLine.indexOf(':');
      if (separator <= 0) continue;

      final rawLabel = cleanedLine.substring(0, separator).trim();
      final rawFieldValue = cleanedLine.substring(separator + 1).trim();
      if (rawFieldValue.isEmpty) continue;

      final label = _canonicalLabel(rawLabel);
      if (_shouldHideLabel(label)) continue;

      final value = label == 'Urgência'
          ? _translateMatrixLevel(rawFieldValue)
          : rawFieldValue;
      fields.add(TicketFormSummaryField(label: label, value: value));
    }

    return TicketFormSummary(
      description: descriptionLines.join('\n').trim(),
      fields: List.unmodifiable(fields),
    );
  }

  String asPlainText() {
    final buffer = StringBuffer();
    if (description.trim().isNotEmpty) {
      buffer.writeln(description.trim());
    }
    for (final field in fields) {
      buffer.writeln('${field.label}: ${field.value}');
    }
    return buffer.toString().trim();
  }

  static bool _isSeparator(String line) {
    return RegExp(r'^[-_=\s]+$').hasMatch(line);
  }

  static bool _shouldHideLabel(String label) {
    return label == 'Anexo' || label == 'Anexos';
  }

  static String _canonicalLabel(String rawLabel) {
    final normalized = _normalize(rawLabel);
    switch (normalized) {
      case 'servico':
        return 'Serviço';
      case 'atendimento para':
        return 'Atendimento para';
      case 'nome (outra pessoa)':
      case 'nome outra pessoa':
        return 'Nome da pessoa';
      case 'telefone':
        return 'Telefone';
      case 'localizacao':
        return 'Localização';
      case 'urgencia':
        return 'Urgência';
      case 'tipo':
        return 'Tipo';
      case 'campo extra':
        return 'Campo extra';
      case 'anexo':
        return 'Anexo';
      case 'anexos':
        return 'Anexos';
      default:
        return rawLabel.trim();
    }
  }

  static String _translateMatrixLevel(String rawValue) {
    final level = int.tryParse(rawValue.trim());
    if (level == null) return rawValue.trim();

    switch (level) {
      case 1:
        return 'Muito Baixa';
      case 2:
        return 'Baixa';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Muito Alta';
      case 6:
        return 'Critica';
      default:
        return 'Media';
    }
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
