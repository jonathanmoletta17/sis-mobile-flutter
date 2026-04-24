import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/widgets/service_card.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_action_badge.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum ServiceCatalogSurfaceVariant { ready, pendingSync, entityUndefined }

class ServiceCatalogSurfacePreview extends StatelessWidget {
  final ServiceCatalogSurfaceVariant variant;

  const ServiceCatalogSurfacePreview({super.key, required this.variant});

  int get _pendingCount => switch (variant) {
        ServiceCatalogSurfaceVariant.ready => 0,
        ServiceCatalogSurfaceVariant.pendingSync => 3,
        ServiceCatalogSurfaceVariant.entityUndefined => 0,
      };

  String get _entityLabel => switch (variant) {
        ServiceCatalogSurfaceVariant.ready => 'Casa Civil RS > Atendimento',
        ServiceCatalogSurfaceVariant.pendingSync =>
          'Casa Civil RS > Atendimento',
        ServiceCatalogSurfaceVariant.entityUndefined => 'Entidade nao definida',
      };

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Servicos',
        subtitle: 'Atendimento operacional SIS',
        actions: [
          if (_pendingCount > 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.cloud_upload_outlined),
                ),
                Positioned(
                  right: 6,
                  top: 8,
                  child: SisActionBadge(count: _pendingCount),
                ),
              ],
            ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 760
                    ? 3
                    : constraints.maxWidth >= 460
                        ? 2
                        : 1;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    gradient: const LinearGradient(
                      colors: [AppColors.brandDark, AppColors.brand],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atendimento pronto para operar',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.textInverse),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Abra novos chamados, acompanhe pendencias e acesse as conversas ativas a partir de uma unica superficie.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoPill(
                            icon: Icons.account_tree_outlined,
                            label: _entityLabel,
                          ),
                          _InfoPill(
                            icon: Icons.cloud_sync_outlined,
                            label: _pendingCount > 0
                                ? '$_pendingCount pendente(s) de sincronizacao'
                                : 'Sem pendencias de sincronizacao',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.brandDark,
                              minimumSize: const Size(0, 48),
                            ),
                            icon: const Icon(Icons.list_alt_outlined),
                            label: const Text('Meus Chamados'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textInverse,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Conversas'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SisSectionHeader(
                  title: 'Categorias',
                  subtitle:
                      'Escolha o servico a partir do catalogo operacional da SIS.',
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: crossAxisCount == 1 ? 2.25 : 0.98,
                  children: [
                    ServiceCard(service: workbenchCriticalService),
                    ServiceCard(service: workbenchOperationalService),
                    ServiceCard(service: workbenchFormService),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textInverse),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
