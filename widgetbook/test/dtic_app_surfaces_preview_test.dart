import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/theme/app_theme.dart';
import 'package:sis_mobile_widgetbook/previews/dtic_app_surfaces_preview.dart';

void main() {
  testWidgets('renders DTIC login preview', (tester) async {
    await _pump(
      tester,
      const DticLoginSurfacePreview(variant: DticLoginSurfaceVariant.failure),
    );

    expect(find.text('DTIC Mobile'), findsOneWidget);
    expect(find.textContaining('Falha na autenticacao DTIC'), findsOneWidget);
  });

  testWidgets('renders DTIC catalog preview', (tester) async {
    await _pump(
      tester,
      const DticCatalogSurfacePreview(variant: DticCatalogSurfaceVariant.ready),
    );

    expect(find.text('Central DTIC'), findsOneWidget);
    expect(find.text('AJUDA - SEI'), findsOneWidget);
  });

  testWidgets('renders DTIC tickets preview', (tester) async {
    await _pump(
      tester,
      const DticTicketsSurfacePreview(
        variant: DticTicketsSurfaceVariant.populated,
      ),
    );

    expect(find.text('Meus chamados DTIC'), findsOneWidget);
    expect(find.text('Acesso ao sistema SEI'), findsOneWidget);
  });

  testWidgets('renders DTIC conversations preview', (tester) async {
    await _pump(
      tester,
      const DticConversationsSurfacePreview(
        variant: DticConversationsSurfaceVariant.populated,
      ),
    );

    expect(find.text('Conversas DTIC'), findsOneWidget);
    expect(find.text('Acesso ao sistema SEI'), findsOneWidget);
  });

  testWidgets('renders DTIC ticket detail response preview', (tester) async {
    await _pump(
      tester,
      const DticTicketDetailSurfacePreview(
        variant: DticTicketDetailSurfaceVariant.responseEnabled,
      ),
    );

    expect(find.text('Acoes habilitadas'), findsOneWidget);
    expect(find.text('Acoes do chamado'), findsOneWidget);
    expect(find.text('Anexos selecionados: 2'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: child));
  await tester.pump();
}
