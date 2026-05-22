class GlpiEntityRef {
  const GlpiEntityRef({required this.id, required this.name});

  final int id;
  final String name;

  bool get isValid => id > 0 && name.trim().isNotEmpty;

  @override
  String toString() => '$name (#$id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlpiEntityRef && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class GlpiProfileRef {
  const GlpiProfileRef({
    required this.id,
    required this.name,
    this.entityId,
    this.entityName,
    this.isRecursive = false,
  });

  final int id;
  final String name;
  final int? entityId;
  final String? entityName;
  final bool isRecursive;

  bool get isValid => id > 0 && name.trim().isNotEmpty;

  @override
  String toString() => '$name (#$id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlpiProfileRef &&
          other.id == id &&
          other.name == name &&
          other.entityId == entityId &&
          other.entityName == entityName &&
          other.isRecursive == isRecursive;

  @override
  int get hashCode => Object.hash(id, name, entityId, entityName, isRecursive);
}

class GlpiGroupRef {
  const GlpiGroupRef({
    required this.id,
    required this.name,
    this.isAssign = false,
    this.isUserGroup = true,
    this.isManager = false,
  });

  final int id;
  final String name;
  final bool isAssign;
  final bool isUserGroup;
  final bool isManager;

  bool get isValid => id > 0 && name.trim().isNotEmpty;

  @override
  String toString() => '$name (#$id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlpiGroupRef &&
          other.id == id &&
          other.name == name &&
          other.isAssign == isAssign &&
          other.isUserGroup == isUserGroup &&
          other.isManager == isManager;

  @override
  int get hashCode => Object.hash(id, name, isAssign, isUserGroup, isManager);
}

int? readGlpiInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

String normalizeGlpiText(String? value) {
  final text = (value ?? '').trim().toLowerCase();
  return text
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');
}
