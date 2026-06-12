import 'glpi_identity.dart';

class SessionContext {
  const SessionContext({
    required this.userId,
    required this.username,
    required this.activeProfile,
    this.activeEntity,
    this.defaultEntityId,
    this.ticketCreationEntity,
    this.availableEntities = const [],
    this.availableProfiles = const [],
    this.groups = const [],
    this.metadataEtag,
    this.snapshotHash,
    this.warnings = const [],
  });

  final int? userId;
  final String? username;
  final GlpiProfileRef? activeProfile;
  final GlpiEntityRef? activeEntity;
  final int? defaultEntityId;
  final GlpiEntityRef? ticketCreationEntity;
  final List<GlpiEntityRef> availableEntities;
  final List<GlpiProfileRef> availableProfiles;
  final List<GlpiGroupRef> groups;
  final String? metadataEtag;
  final String? snapshotHash;
  final List<String> warnings;

  bool get isValid =>
      userId != null &&
      userId! > 0 &&
      (username?.trim().isNotEmpty ?? false) &&
      (activeProfile?.isValid ?? false);

  factory SessionContext.fromGlpiSession(
    Map<String, dynamic> session, {
    GlpiEntityRef? ticketCreationEntity,
    String? metadataEtag,
    String? snapshotHash,
  }) {
    final warnings = <String>[];
    final userId = readGlpiInt(session['glpiID']);
    final username = session['glpiname']?.toString();

    if (userId == null || userId <= 0 || (username?.trim().isEmpty ?? true)) {
      warnings.add('Sessão sem usuário GLPI identificado');
    }

    final rawProfile = session['glpiactiveprofile'];
    GlpiProfileRef? profile;
    if (rawProfile is Map) {
      final profileMap = Map<String, dynamic>.from(rawProfile);
      profile = GlpiProfileRef(
        id: readGlpiInt(profileMap['id']) ?? 0,
        name: profileMap['name']?.toString().trim() ?? '',
      );
    }

    if (!(profile?.isValid ?? false)) {
      warnings.add('Sessão sem perfil ativo GLPI identificado');
    }

    final activeEntityId = readGlpiInt(session['glpiactive_entity']);
    final activeEntityName = session['glpiactive_entity_name']
        ?.toString()
        .trim();
    final activeEntity =
        activeEntityId != null &&
            activeEntityId > 0 &&
            activeEntityName != null &&
            activeEntityName.isNotEmpty
        ? GlpiEntityRef(id: activeEntityId, name: activeEntityName)
        : null;

    final availableEntities = <GlpiEntityRef>[];
    if (rawProfile is Map) {
      final entities = rawProfile['entities'];
      if (entities is Map) {
        for (final value in entities.values) {
          if (value is! Map) continue;
          final entity = Map<String, dynamic>.from(value);
          final id = readGlpiInt(entity['id']);
          final name = entity['name']?.toString().trim();
          if (id != null && id > 0 && name != null && name.isNotEmpty) {
            availableEntities.add(GlpiEntityRef(id: id, name: name));
          }
        }
      }
    }

    return SessionContext(
      userId: userId,
      username: username,
      activeProfile: profile,
      activeEntity: activeEntity,
      defaultEntityId: readGlpiInt(session['glpidefault_entity']),
      ticketCreationEntity: ticketCreationEntity,
      availableEntities: availableEntities,
      groups: _parseGroups(session['glpigroups']),
      metadataEtag: metadataEtag,
      snapshotHash: snapshotHash,
      warnings: warnings,
    );
  }

  static List<GlpiGroupRef> _parseGroups(dynamic rawGroups) {
    final groups = <GlpiGroupRef>[];

    void addGroup({required dynamic rawId, required dynamic rawName}) {
      final id = readGlpiInt(rawId);
      final name = rawName?.toString().trim();
      if (id == null || id <= 0 || name == null || name.isEmpty) return;
      groups.add(GlpiGroupRef(id: id, name: name));
    }

    if (rawGroups is Map) {
      for (final entry in rawGroups.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          addGroup(
            rawId: map['id'] ?? key,
            rawName: map['name'] ?? map['completename'] ?? value,
          );
        } else {
          addGroup(rawId: key, rawName: value);
        }
      }
    } else if (rawGroups is List) {
      for (final value in rawGroups) {
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          addGroup(
            rawId: map['id'],
            rawName: map['name'] ?? map['completename'],
          );
        } else {
          addGroup(rawId: value, rawName: 'Grupo $value');
        }
      }
    }

    return List<GlpiGroupRef>.unmodifiable(groups);
  }

  SessionContext copyWith({
    GlpiEntityRef? ticketCreationEntity,
    List<GlpiGroupRef>? groups,
    List<GlpiProfileRef>? availableProfiles,
    String? metadataEtag,
    String? snapshotHash,
  }) {
    return SessionContext(
      userId: userId,
      username: username,
      activeProfile: activeProfile,
      activeEntity: activeEntity,
      defaultEntityId: defaultEntityId,
      ticketCreationEntity: ticketCreationEntity ?? this.ticketCreationEntity,
      availableEntities: availableEntities,
      availableProfiles: availableProfiles ?? this.availableProfiles,
      groups: groups ?? this.groups,
      metadataEtag: metadataEtag ?? this.metadataEtag,
      snapshotHash: snapshotHash ?? this.snapshotHash,
      warnings: warnings,
    );
  }
}
