import 'glpi_identity.dart';

enum GlpiGroupSemantic { maintenance, conservation, ggConservation, unknown }

class GlpiGroupSemantics {
  static GlpiGroupSemantic classify(GlpiGroupRef group) =>
      classifyName(group.name);

  static GlpiGroupSemantic classifyName(String? rawName) {
    final name = normalizeGlpiText(rawName);
    if (name.isEmpty) return GlpiGroupSemantic.unknown;

    final isConservation = name.contains('conservacao');
    final isGg = name.contains('gg');
    if (isGg && isConservation) return GlpiGroupSemantic.ggConservation;
    if (name.contains('manutencao')) return GlpiGroupSemantic.maintenance;
    if (isConservation) return GlpiGroupSemantic.conservation;
    return GlpiGroupSemantic.unknown;
  }

  static bool isMaintenance(GlpiGroupRef group) =>
      classify(group) == GlpiGroupSemantic.maintenance;

  static bool isConservation(GlpiGroupRef group) =>
      classify(group) == GlpiGroupSemantic.conservation;

  static bool isGgConservation(GlpiGroupRef group) =>
      classify(group) == GlpiGroupSemantic.ggConservation;
}
