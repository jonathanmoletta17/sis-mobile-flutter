import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';

void main() {
  group('GlpiStatusMapper', () {
    test('parses canonical numeric codes', () {
      expect(GlpiStatusMapper.tryParse(1), GlpiStatus.novo);
      expect(GlpiStatusMapper.tryParse(2), GlpiStatus.emAtendimento);
      expect(GlpiStatusMapper.tryParse(3), GlpiStatus.planejado);
      expect(GlpiStatusMapper.tryParse(4), GlpiStatus.pendente);
      expect(GlpiStatusMapper.tryParse(5), GlpiStatus.solucionado);
      expect(GlpiStatusMapper.tryParse(6), GlpiStatus.fechado);
    });

    test('parses canonical textual labels', () {
      expect(GlpiStatusMapper.tryParse('Novo'), GlpiStatus.novo);
      expect(
        GlpiStatusMapper.tryParse('Em Atendimento'),
        GlpiStatus.emAtendimento,
      );
      expect(GlpiStatusMapper.tryParse('Planejado'), GlpiStatus.planejado);
      expect(GlpiStatusMapper.tryParse('Pendente'), GlpiStatus.pendente);
      expect(GlpiStatusMapper.tryParse('Solucionado'), GlpiStatus.solucionado);
      expect(GlpiStatusMapper.tryParse('Fechado'), GlpiStatus.fechado);
    });

    test('maps legacy textual variants to canonical status', () {
      expect(GlpiStatusMapper.tryParse('Em andamento'), GlpiStatus.planejado);
      expect(GlpiStatusMapper.tryParse('Concluído'), GlpiStatus.fechado);
    });

    test('returns offline label for offline tickets', () {
      expect(
        GlpiStatusMapper.label('Pendente (Offline)'),
        GlpiStatusMapper.offlineLabel,
      );
      expect(GlpiStatusMapper.isOffline('Pendente (Offline)'), isTrue);
    });

    test('interaction flags follow canonical status rules', () {
      expect(GlpiStatusMapper.isOpenForInteraction(1), isTrue);
      expect(GlpiStatusMapper.isOpenForInteraction(2), isTrue);
      expect(GlpiStatusMapper.isOpenForInteraction(3), isTrue);
      expect(GlpiStatusMapper.isOpenForInteraction(4), isTrue);
      expect(GlpiStatusMapper.isOpenForInteraction(5), isFalse);
      expect(GlpiStatusMapper.isOpenForInteraction(6), isFalse);
      expect(GlpiStatusMapper.isClosed(6), isTrue);
      expect(GlpiStatusMapper.isClosed('Fechado'), isTrue);
      expect(GlpiStatusMapper.isSolved('Solucionado'), isTrue);
    });
  });
}
