import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/theme/app_theme.dart';
import 'package:sis_mobile_widgetbook/previews/dtic_formcreator_surface_preview.dart';

void main() {
  testWidgets('renders DTIC FormCreator simple preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const DticFormCreatorSurfacePreview(),
      ),
    );

    expect(find.text('INCIDENTE'), findsOneWidget);
    expect(find.text('Dados do incidente'), findsOneWidget);
  });

  testWidgets('renders DTIC FormCreator large select preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const DticFormCreatorSurfacePreview(
          variant: DticFormCreatorSurfaceVariant.largeSelect,
        ),
      ),
    );

    expect(find.text('SISTEMAS INTERNOS'), findsOneWidget);
    expect(find.text('PROA'), findsOneWidget);
  });

  testWidgets('renders DTIC FormCreator complex blocked preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const DticFormCreatorSurfacePreview(
          variant: DticFormCreatorSurfaceVariant.complexBlocked,
        ),
      ),
    );

    expect(find.text('EMAIL E APLICATIVOS OFFICE 365'), findsOneWidget);
    expect(
      find.textContaining('Abra este atendimento pelo GLPI web'),
      findsOneWidget,
    );
  });
}
