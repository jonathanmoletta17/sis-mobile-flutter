import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class SisActionBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;

  const SisActionBadge({super.key, required this.count, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.surface, width: 1.2),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        display,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textInverse,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
