import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/service_data.dart';
import '../screens/generic_form_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ServiceCard extends StatelessWidget {
  final ServiceCategory service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GenericFormScreen(service: service),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useWideLayout = constraints.maxWidth >= 280;

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: useWideLayout
                  ? _WideServiceCardContent(service: service)
                  : _CompactServiceCardContent(service: service),
            );
          },
        ),
      ),
    );
  }
}

class _WideServiceCardContent extends StatelessWidget {
  final ServiceCategory service;

  const _WideServiceCardContent({required this.service});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceIcon(color: service.color, icon: service.icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ServiceGovernanceBadges(service: service),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    'Abrir solicitação',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: service.color),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: service.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactServiceCardContent extends StatelessWidget {
  final ServiceCategory service;

  const _CompactServiceCardContent({required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ServiceIcon(color: service.color, icon: service.icon),
        const Spacer(),
        Text(
          service.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        _ServiceGovernanceBadges(service: service),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'Abrir solicitação',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: service.color),
            ),
            const Spacer(),
            Icon(Icons.arrow_outward_rounded, size: 18, color: service.color),
          ],
        ),
      ],
    );
  }
}

class _ServiceGovernanceBadges extends StatelessWidget {
  final ServiceCategory service;

  const _ServiceGovernanceBadges({required this.service});

  @override
  Widget build(BuildContext context) {
    // Exibe apenas o grupo de atribuição (ex.: CC-MANUTENCAO). O domínio
    // (ex.: "Manutenção") foi removido por ser redundante com o grupo.
    final group = service.assignmentGroupLabel?.trim();
    if (group == null || group.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: service.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        group,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _ServiceIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: FaIcon(icon, size: 24, color: color),
    );
  }
}
