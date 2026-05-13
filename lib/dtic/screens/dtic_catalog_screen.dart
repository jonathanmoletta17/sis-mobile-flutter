import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/ui/sis_empty_state.dart';
import '../../widgets/ui/glpi_app_navigation.dart';
import '../../widgets/ui/sis_loading_state.dart';
import '../../widgets/ui/sis_page_scaffold.dart';
import '../../widgets/ui/sis_section_header.dart';
import '../models/dtic_formcreator_models.dart';
import '../state/dtic_app_state.dart';
import 'dtic_chat_overview_screen.dart';
import 'dtic_dynamic_form_screen.dart';
import 'dtic_my_tickets_screen.dart';

class DticCatalogScreen extends StatelessWidget {
  const DticCatalogScreen({super.key});

  void _openShellDestination(BuildContext context, GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        return;
      case GlpiAppSection.tickets:
        replaceAppRoot(context, const DticMyTicketsScreen());
      case GlpiAppSection.conversations:
        replaceAppRoot(context, const DticChatOverviewScreen());
      case GlpiAppSection.offline:
        return;
    }
  }

  Future<void> _refresh(DticAppState state) async {
    await state.loadCatalog();
    await state.loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DticAppState>();
    final catalog = state.catalog;

    return SisPageScaffold(
      title: 'DTIC Mobile',
      subtitle: state.activeEntityName ?? state.username ?? 'GLPI DTIC',
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.services,
        destinations: dticShellDestinations(),
        onDestinationSelected: (destination) {
          _openShellDestination(context, destination);
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Meus chamados',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DticMyTicketsScreen()),
            );
          },
          icon: const Icon(Icons.confirmation_number_outlined),
        ),
        IconButton(
          tooltip: 'Sair',
          onPressed: () => context.read<DticAppState>().logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => _refresh(context.read<DticAppState>()),
        child: catalog == null
            ? const SisLoadingState(
                title: 'Carregando catalogo DTIC',
                message: 'Lendo atendimentos disponiveis no GLPI DTIC.',
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _CatalogHero(state: state, formCount: catalog.forms.length),
                  const SizedBox(height: AppSpacing.lg),
                  SisSectionHeader(
                    title: 'Solicitacoes disponiveis',
                    subtitle: 'Escolha o atendimento que deseja abrir.',
                    trailing: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DticMyTicketsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: Text('${state.tickets.length} chamados'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (catalog.forms.isEmpty)
                    const SisEmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'Nenhum formulario ativo',
                      message:
                          'O catalogo DTIC nao retornou formularios ativos.',
                    )
                  else
                    for (final form in catalog.forms)
                      _DticFormCard(catalog: catalog, form: form),
                ],
              ),
      ),
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({required this.state, required this.formCount});

  final DticAppState state;
  final int formCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent_outlined,
            color: AppColors.textInverse,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central DTIC',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$formCount solicitacoes ativas | ${state.profile ?? 'perfil GLPI'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textOnBrandMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DticFormCard extends StatelessWidget {
  const _DticFormCard({required this.catalog, required this.form});

  final DticFormCatalog catalog;
  final DticForm form;

  @override
  Widget build(BuildContext context) {
    final questions = catalog.questions
        .where((question) => question.formId == form.id)
        .toList();
    final requiredCount = questions
        .where((question) => question.required)
        .length;
    final fileCount = questions.where((question) => question.isFile).length;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.infoSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.dynamic_form_outlined, color: AppColors.info),
        ),
        title: Text(form.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            '${questions.length} campos | $requiredCount obrigatorios | '
            '$fileCount anexos',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DticDynamicFormScreen(form: form),
            ),
          );
        },
      ),
    );
  }
}
