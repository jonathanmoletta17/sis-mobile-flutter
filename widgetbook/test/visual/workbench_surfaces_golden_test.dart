import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_widgetbook/previews/chat_overview_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/dtic_app_surfaces_preview.dart';
import 'package:sis_mobile_widgetbook/previews/dtic_formcreator_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/form_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/login_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/my_tickets_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/offline_queue_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/service_catalog_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/ticket_message_surface_preview.dart';
import 'package:sis_mobile_widgetbook/previews/ticket_detail_surface_preview.dart';

void main() {
  group('SIS Mobile workbench surfaces', () {
    const mobileSurface = BoxConstraints.tightFor(width: 390, height: 844);

    goldenTest(
      'renders login states',
      fileName: 'login_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: _precacheImagesAndPump,
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'idle',
            child: LoginSurfacePreview(variant: LoginSurfaceVariant.idle),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: LoginSurfacePreview(variant: LoginSurfaceVariant.loading),
          ),
          GoldenTestScenario(
            name: 'validation',
            child: LoginSurfacePreview(variant: LoginSurfaceVariant.validation),
          ),
          GoldenTestScenario(
            name: 'failure',
            child: LoginSurfacePreview(variant: LoginSurfaceVariant.failure),
          ),
        ],
      ),
    );

    goldenTest(
      'renders service catalog states',
      fileName: 'service_catalog_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'ready',
            child: ServiceCatalogSurfacePreview(
              variant: ServiceCatalogSurfaceVariant.ready,
            ),
          ),
          GoldenTestScenario(
            name: 'pending-sync',
            child: ServiceCatalogSurfacePreview(
              variant: ServiceCatalogSurfaceVariant.pendingSync,
            ),
          ),
          GoldenTestScenario(
            name: 'entity-undefined',
            child: ServiceCatalogSurfacePreview(
              variant: ServiceCatalogSurfaceVariant.entityUndefined,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders offline queue states',
      fileName: 'offline_queue_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'pending',
            child: OfflineQueueSurfacePreview(
              variant: OfflineQueueSurfaceVariant.pending,
            ),
          ),
          GoldenTestScenario(
            name: 'syncing',
            child: OfflineQueueSurfacePreview(
              variant: OfflineQueueSurfaceVariant.syncing,
            ),
          ),
          GoldenTestScenario(
            name: 'error',
            child: OfflineQueueSurfacePreview(
              variant: OfflineQueueSurfaceVariant.error,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: OfflineQueueSurfacePreview(
              variant: OfflineQueueSurfaceVariant.empty,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders my tickets states',
      fileName: 'my_tickets_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'populated',
            child: MyTicketsSurfacePreview(
              variant: MyTicketsSurfaceVariant.populated,
            ),
          ),
          GoldenTestScenario(
            name: 'filtered',
            child: MyTicketsSurfacePreview(
              variant: MyTicketsSurfaceVariant.populated,
              filterActive: true,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: MyTicketsSurfacePreview(
              variant: MyTicketsSurfaceVariant.empty,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: MyTicketsSurfacePreview(
              variant: MyTicketsSurfaceVariant.loading,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders conversation states',
      fileName: 'chat_overview_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'populated',
            child: ChatOverviewSurfacePreview(
              variant: ChatOverviewSurfaceVariant.populated,
            ),
          ),
          GoldenTestScenario(
            name: 'filtered',
            child: ChatOverviewSurfacePreview(
              variant: ChatOverviewSurfaceVariant.populated,
              filterActive: true,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: ChatOverviewSurfacePreview(
              variant: ChatOverviewSurfaceVariant.empty,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: ChatOverviewSurfacePreview(
              variant: ChatOverviewSurfaceVariant.loading,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders ticket detail states',
      fileName: 'ticket_detail_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'operator',
            child: TicketDetailSurfacePreview(
              variant: TicketDetailSurfaceVariant.operatorView,
            ),
          ),
          GoldenTestScenario(
            name: 'requester',
            child: TicketDetailSurfacePreview(
              variant: TicketDetailSurfaceVariant.requesterView,
            ),
          ),
          GoldenTestScenario(
            name: 'offline',
            child: TicketDetailSurfacePreview(
              variant: TicketDetailSurfaceVariant.offline,
            ),
          ),
          GoldenTestScenario(
            name: 'attachments-loading',
            child: TicketDetailSurfacePreview(
              variant: TicketDetailSurfaceVariant.attachmentsLoading,
            ),
          ),
          GoldenTestScenario(
            name: 'attachments-error',
            child: TicketDetailSurfacePreview(
              variant: TicketDetailSurfaceVariant.attachmentsError,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders ticket message states',
      fileName: 'ticket_message_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'active',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.active,
            ),
          ),
          GoldenTestScenario(
            name: 'solution-pending',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.solutionPending,
            ),
          ),
          GoldenTestScenario(
            name: 'closed',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.closed,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.empty,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.loading,
            ),
          ),
          GoldenTestScenario(
            name: 'error',
            child: TicketMessageSurfacePreview(
              variant: TicketMessageSurfaceVariant.error,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders form states',
      fileName: 'form_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'pristine',
            child: FormSurfacePreview(variant: FormSurfaceVariant.pristine),
          ),
          GoldenTestScenario(
            name: 'seeded',
            child: FormSurfacePreview(variant: FormSurfaceVariant.seeded),
          ),
          GoldenTestScenario(
            name: 'validation-error',
            child: FormSurfacePreview(
              variant: FormSurfaceVariant.validationError,
            ),
          ),
          GoldenTestScenario(
            name: 'submitting',
            child: FormSurfacePreview(variant: FormSurfaceVariant.submitting),
          ),
          GoldenTestScenario(
            name: 'submitted',
            child: FormSurfacePreview(variant: FormSurfaceVariant.submitted),
          ),
          GoldenTestScenario(
            name: 'offline-fallback',
            child: FormSurfacePreview(
              variant: FormSurfaceVariant.offlineFallback,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC login states',
      fileName: 'dtic_login_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'idle',
            child: DticLoginSurfacePreview(
              variant: DticLoginSurfaceVariant.idle,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: DticLoginSurfacePreview(
              variant: DticLoginSurfaceVariant.loading,
            ),
          ),
          GoldenTestScenario(
            name: 'failure',
            child: DticLoginSurfacePreview(
              variant: DticLoginSurfaceVariant.failure,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC catalog states',
      fileName: 'dtic_catalog_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'ready',
            child: DticCatalogSurfacePreview(
              variant: DticCatalogSurfaceVariant.ready,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: DticCatalogSurfacePreview(
              variant: DticCatalogSurfaceVariant.loading,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: DticCatalogSurfacePreview(
              variant: DticCatalogSurfaceVariant.empty,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC tickets states',
      fileName: 'dtic_tickets_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'populated',
            child: DticTicketsSurfacePreview(
              variant: DticTicketsSurfaceVariant.populated,
            ),
          ),
          GoldenTestScenario(
            name: 'filtered-empty',
            child: DticTicketsSurfacePreview(
              variant: DticTicketsSurfaceVariant.filteredEmpty,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: DticTicketsSurfacePreview(
              variant: DticTicketsSurfaceVariant.loading,
            ),
          ),
          GoldenTestScenario(
            name: 'error',
            child: DticTicketsSurfacePreview(
              variant: DticTicketsSurfaceVariant.error,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC conversation states',
      fileName: 'dtic_conversations_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'populated',
            child: DticConversationsSurfacePreview(
              variant: DticConversationsSurfaceVariant.populated,
            ),
          ),
          GoldenTestScenario(
            name: 'empty',
            child: DticConversationsSurfacePreview(
              variant: DticConversationsSurfaceVariant.empty,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: DticConversationsSurfacePreview(
              variant: DticConversationsSurfaceVariant.loading,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC ticket detail states',
      fileName: 'dtic_ticket_detail_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'read-only',
            child: DticTicketDetailSurfacePreview(
              variant: DticTicketDetailSurfaceVariant.readOnly,
            ),
          ),
          GoldenTestScenario(
            name: 'response-enabled',
            child: DticTicketDetailSurfacePreview(
              variant: DticTicketDetailSurfaceVariant.responseEnabled,
            ),
          ),
          GoldenTestScenario(
            name: 'closed',
            child: DticTicketDetailSurfacePreview(
              variant: DticTicketDetailSurfaceVariant.closed,
            ),
          ),
          GoldenTestScenario(
            name: 'loading',
            child: DticTicketDetailSurfacePreview(
              variant: DticTicketDetailSurfaceVariant.loading,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders DTIC FormCreator states',
      fileName: 'dtic_formcreator_surface_states',
      constraints: const BoxConstraints(maxWidth: 860),
      pumpBeforeTest: pumpNTimes(2),
      builder: () => GoldenTestGroup(
        columns: 2,
        scenarioConstraints: mobileSurface,
        children: [
          GoldenTestScenario(
            name: 'simple',
            child: DticFormCreatorSurfacePreview(
              variant: DticFormCreatorSurfaceVariant.simple,
            ),
          ),
          GoldenTestScenario(
            name: 'large-select',
            child: DticFormCreatorSurfacePreview(
              variant: DticFormCreatorSurfaceVariant.largeSelect,
            ),
          ),
          GoldenTestScenario(
            name: 'complex-blocked',
            child: DticFormCreatorSurfacePreview(
              variant: DticFormCreatorSurfaceVariant.complexBlocked,
            ),
          ),
        ],
      ),
    );
  });
}

Future<void> _precacheImagesAndPump(WidgetTester tester) async {
  await tester.runAsync(() async {
    final images = <Future<void>>[];
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      images.add(precacheImage(widget.image, element));
    }
    await Future.wait(images);
  });
  await tester.pump();
}
