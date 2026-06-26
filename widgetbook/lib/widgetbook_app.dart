import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/data/service_data.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/service_card.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';
import 'package:widgetbook/widgetbook.dart';

import 'previews/chat_overview_surface_preview.dart';
import 'previews/dtic_app_surfaces_preview.dart';
import 'previews/dtic_formcreator_surface_preview.dart';
import 'previews/form_surface_preview.dart';
import 'previews/login_surface_preview.dart';
import 'previews/my_tickets_surface_preview.dart';
import 'previews/offline_queue_surface_preview.dart';
import 'previews/service_catalog_surface_preview.dart';
import 'previews/sis_checklist_surface_preview.dart';
import 'previews/ticket_message_surface_preview.dart';
import 'previews/ticket_detail_surface_preview.dart';
import 'previews/workbench_fixtures.dart';
import 'workbench_surface.dart';

class SisMobileWidgetbookApp extends StatelessWidget {
  const SisMobileWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookComponent(
          name: 'SisChecklistSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Catálogo · Super-Admin',
              builder: (context) => const SisChecklistSurfacePreview(
                variant: SisChecklistSurfaceVariant.catalogSuperAdmin,
              ),
            ),
            WidgetbookUseCase(
              name: 'Catálogo · Solicitante (oculto)',
              builder: (context) => const SisChecklistSurfacePreview(
                variant: SisChecklistSurfaceVariant.catalogSolicitante,
              ),
            ),
            WidgetbookUseCase(
              name: 'Formulário · obrigatório faltando',
              builder: (context) => const SisChecklistSurfacePreview(
                variant: SisChecklistSurfaceVariant.formMissingRequired,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SisStatusChip',
          useCases: [
            WidgetbookUseCase(
              name: 'Brand',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(label: 'Novo', tone: AppStatusTone.brand),
              ),
            ),
            WidgetbookUseCase(
              name: 'Info',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(
                  label: 'Em atendimento',
                  tone: AppStatusTone.info,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Success',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(
                  label: 'Resolvido',
                  tone: AppStatusTone.success,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Warning',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(
                  label: 'Pendente',
                  tone: AppStatusTone.warning,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Danger',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(
                  label: 'Offline',
                  tone: AppStatusTone.danger,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Neutral',
              builder: (context) => const WorkbenchSurface(
                centered: true,
                child: SisStatusChip(
                  label: 'Fechado',
                  tone: AppStatusTone.neutral,
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SisEmptyState',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const WorkbenchSurface(
                child: SisEmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Nenhum resultado encontrado',
                  message:
                      'Revise os filtros aplicados ou ajuste o contexto da consulta.',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Action',
              builder: (context) => WorkbenchSurface(
                child: SisEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Sem conexao com o GLPI',
                  message:
                      'Voce ainda pode revisar o estado local e tentar novamente mais tarde.',
                  actionLabel: 'Tentar novamente',
                  onAction: () {},
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SisLoadingState',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const WorkbenchSurface(
                child: SisLoadingState(
                  title: 'Carregando chamados',
                  message: 'Sincronizando a fila e preparando a superficie.',
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SisSectionHeader',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const WorkbenchSurface(
                child: SisSectionHeader(
                  title: 'Chamados recentes',
                  subtitle:
                      'Priorize a fila por contexto operacional e atividade nova.',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Trailing',
              builder: (context) => const WorkbenchSurface(
                child: SisSectionHeader(
                  title: 'Conversas em andamento',
                  subtitle:
                      'Acompanhe tickets que exigem resposta ou validacao.',
                  trailing: SisStatusChip(
                    label: '12',
                    tone: AppStatusTone.info,
                  ),
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'ServiceCard',
          useCases: [
            WidgetbookUseCase(
              name: 'Critical Service',
              builder: (context) => WorkbenchSurface(
                maxWidth: 360,
                centered: true,
                child: ServiceCard(service: serviceCategories.first),
              ),
            ),
            WidgetbookUseCase(
              name: 'Operational Service',
              builder: (context) => WorkbenchSurface(
                maxWidth: 360,
                centered: true,
                child: ServiceCard(service: workbenchOperationalService),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SisPageScaffold',
          useCases: [
            WidgetbookUseCase(
              name: 'Catalog Shell',
              builder: (context) => const _ShellCatalogPreview(),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC Login Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Idle',
              builder: (context) => const DticLoginSurfacePreview(
                variant: DticLoginSurfaceVariant.idle,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const DticLoginSurfacePreview(
                variant: DticLoginSurfaceVariant.loading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Failure',
              builder: (context) => const DticLoginSurfacePreview(
                variant: DticLoginSurfaceVariant.failure,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC Catalog Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Ready',
              builder: (context) => const DticCatalogSurfacePreview(
                variant: DticCatalogSurfaceVariant.ready,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const DticCatalogSurfacePreview(
                variant: DticCatalogSurfaceVariant.loading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const DticCatalogSurfacePreview(
                variant: DticCatalogSurfaceVariant.empty,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC My Tickets Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Populated',
              builder: (context) => const DticTicketsSurfacePreview(
                variant: DticTicketsSurfaceVariant.populated,
              ),
            ),
            WidgetbookUseCase(
              name: 'Filtered Empty',
              builder: (context) => const DticTicketsSurfacePreview(
                variant: DticTicketsSurfaceVariant.filteredEmpty,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const DticTicketsSurfacePreview(
                variant: DticTicketsSurfaceVariant.loading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => const DticTicketsSurfacePreview(
                variant: DticTicketsSurfaceVariant.error,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC Conversations Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Populated',
              builder: (context) => const DticConversationsSurfacePreview(
                variant: DticConversationsSurfaceVariant.populated,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const DticConversationsSurfacePreview(
                variant: DticConversationsSurfaceVariant.empty,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const DticConversationsSurfacePreview(
                variant: DticConversationsSurfaceVariant.loading,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC Ticket Detail Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Read Only',
              builder: (context) => const DticTicketDetailSurfacePreview(
                variant: DticTicketDetailSurfaceVariant.readOnly,
              ),
            ),
            WidgetbookUseCase(
              name: 'Response Enabled',
              builder: (context) => const DticTicketDetailSurfacePreview(
                variant: DticTicketDetailSurfaceVariant.responseEnabled,
              ),
            ),
            WidgetbookUseCase(
              name: 'Closed',
              builder: (context) => const DticTicketDetailSurfacePreview(
                variant: DticTicketDetailSurfaceVariant.closed,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const DticTicketDetailSurfacePreview(
                variant: DticTicketDetailSurfaceVariant.loading,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DTIC Solicitation Surface',
          useCases: [
            WidgetbookUseCase(
              name: 'Simples',
              builder: (context) => const DticFormCreatorSurfacePreview(),
            ),
            WidgetbookUseCase(
              name: 'Select pesquisavel',
              builder: (context) => const DticFormCreatorSurfacePreview(
                variant: DticFormCreatorSurfaceVariant.largeSelect,
              ),
            ),
            WidgetbookUseCase(
              name: 'Condicional avancado',
              builder: (context) => const DticFormCreatorSurfacePreview(
                variant: DticFormCreatorSurfaceVariant.complexBlocked,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'LoginSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Idle',
              builder: (context) =>
                  const LoginSurfacePreview(variant: LoginSurfaceVariant.idle),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const LoginSurfacePreview(
                variant: LoginSurfaceVariant.loading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Validation',
              builder: (context) => const LoginSurfacePreview(
                variant: LoginSurfaceVariant.validation,
              ),
            ),
            WidgetbookUseCase(
              name: 'Failure',
              builder: (context) => const LoginSurfacePreview(
                variant: LoginSurfaceVariant.failure,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'ServiceCatalogSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Ready',
              builder: (context) => const ServiceCatalogSurfacePreview(
                variant: ServiceCatalogSurfaceVariant.ready,
              ),
            ),
            WidgetbookUseCase(
              name: 'Pending Sync',
              builder: (context) => const ServiceCatalogSurfacePreview(
                variant: ServiceCatalogSurfaceVariant.pendingSync,
              ),
            ),
            WidgetbookUseCase(
              name: 'Entity Undefined',
              builder: (context) => const ServiceCatalogSurfacePreview(
                variant: ServiceCatalogSurfaceVariant.entityUndefined,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'OfflineQueueSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Pending',
              builder: (context) => const OfflineQueueSurfacePreview(
                variant: OfflineQueueSurfaceVariant.pending,
              ),
            ),
            WidgetbookUseCase(
              name: 'Syncing',
              builder: (context) => const OfflineQueueSurfacePreview(
                variant: OfflineQueueSurfaceVariant.syncing,
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => const OfflineQueueSurfacePreview(
                variant: OfflineQueueSurfaceVariant.error,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const OfflineQueueSurfacePreview(
                variant: OfflineQueueSurfaceVariant.empty,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'MyTicketsSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Populated',
              builder: (context) => const MyTicketsSurfacePreview(
                variant: MyTicketsSurfaceVariant.populated,
              ),
            ),
            WidgetbookUseCase(
              name: 'Populated With Filters',
              builder: (context) => const MyTicketsSurfacePreview(
                variant: MyTicketsSurfaceVariant.populated,
                filterActive: true,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const MyTicketsSurfacePreview(
                variant: MyTicketsSurfaceVariant.empty,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const MyTicketsSurfacePreview(
                variant: MyTicketsSurfaceVariant.loading,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'ChatOverviewSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Populated',
              builder: (context) => const ChatOverviewSurfacePreview(
                variant: ChatOverviewSurfaceVariant.populated,
              ),
            ),
            WidgetbookUseCase(
              name: 'Filtered',
              builder: (context) => const ChatOverviewSurfacePreview(
                variant: ChatOverviewSurfaceVariant.populated,
                filterActive: true,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const ChatOverviewSurfacePreview(
                variant: ChatOverviewSurfaceVariant.empty,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const ChatOverviewSurfacePreview(
                variant: ChatOverviewSurfaceVariant.loading,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'TicketDetailSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Operator View',
              builder: (context) => const TicketDetailSurfacePreview(
                variant: TicketDetailSurfaceVariant.operatorView,
              ),
            ),
            WidgetbookUseCase(
              name: 'Requester View',
              builder: (context) => const TicketDetailSurfacePreview(
                variant: TicketDetailSurfaceVariant.requesterView,
              ),
            ),
            WidgetbookUseCase(
              name: 'Offline',
              builder: (context) => const TicketDetailSurfacePreview(
                variant: TicketDetailSurfaceVariant.offline,
              ),
            ),
            WidgetbookUseCase(
              name: 'Attachments Loading',
              builder: (context) => const TicketDetailSurfacePreview(
                variant: TicketDetailSurfaceVariant.attachmentsLoading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Attachments Error',
              builder: (context) => const TicketDetailSurfacePreview(
                variant: TicketDetailSurfaceVariant.attachmentsError,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'TicketMessageSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Active',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.active,
              ),
            ),
            WidgetbookUseCase(
              name: 'Solution Pending',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.solutionPending,
              ),
            ),
            WidgetbookUseCase(
              name: 'Closed',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.closed,
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.empty,
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.loading,
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => const TicketMessageSurfacePreview(
                variant: TicketMessageSurfaceVariant.error,
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'FormSurface',
          useCases: [
            WidgetbookUseCase(
              name: 'Pristine',
              builder: (context) => const FormSurfacePreview(
                variant: FormSurfaceVariant.pristine,
              ),
            ),
            WidgetbookUseCase(
              name: 'Seeded',
              builder: (context) =>
                  const FormSurfacePreview(variant: FormSurfaceVariant.seeded),
            ),
            WidgetbookUseCase(
              name: 'Validation Error',
              builder: (context) => const FormSurfacePreview(
                variant: FormSurfaceVariant.validationError,
              ),
            ),
            WidgetbookUseCase(
              name: 'Submitting',
              builder: (context) => const FormSurfacePreview(
                variant: FormSurfaceVariant.submitting,
              ),
            ),
            WidgetbookUseCase(
              name: 'Submitted',
              builder: (context) => const FormSurfacePreview(
                variant: FormSurfaceVariant.submitted,
              ),
            ),
            WidgetbookUseCase(
              name: 'Offline Fallback',
              builder: (context) => const FormSurfacePreview(
                variant: FormSurfaceVariant.offlineFallback,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShellCatalogPreview extends StatelessWidget {
  const _ShellCatalogPreview();

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Servicos',
        subtitle: 'Catalogo operacional do SIS',
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SisSectionHeader(
              title: 'Entrada rapida',
              subtitle:
                  'Abertura objetiva de solicitacoes por servico e contexto.',
            ),
            const SizedBox(height: 16),
            ServiceCard(service: workbenchCriticalService),
            const SizedBox(height: 12),
            ServiceCard(service: workbenchOperationalService),
          ],
        ),
      ),
    );
  }
}
