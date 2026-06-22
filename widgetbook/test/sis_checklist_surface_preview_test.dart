import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/theme/app_theme.dart';
import 'package:sis_mobile_widgetbook/previews/sis_checklist_surface_preview.dart';

void main() {
  Future<void> useTallSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Super-Admin sees the checklist target', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.build(),
      home: const SisChecklistSurfacePreview(
        variant: SisChecklistSurfaceVariant.catalogSuperAdmin,
      ),
    ));
    expect(find.text('HIDRÁULICO ALA RESIDENCIAL'), findsOneWidget);
  });

  testWidgets('Solicitante sees the empty state', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.build(),
      home: const SisChecklistSurfacePreview(
        variant: SisChecklistSurfaceVariant.catalogSolicitante,
      ),
    ));
    expect(find.byKey(const Key('checklist_empty_state')), findsOneWidget);
  });

  testWidgets('form preview shows read-only review button and status banner', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.build(),
      home: const SisChecklistSurfacePreview(
        variant: SisChecklistSurfaceVariant.formMissingRequired,
      ),
    ));
    expect(find.byKey(const Key('checklist_review_button')), findsOneWidget);
    expect(find.byKey(const Key('checklist_submit_button')), findsNothing);
    expect(find.byKey(const Key('checklist_status_banner')), findsOneWidget);
  });
}
