import 'package:flutter/material.dart';

import '../models/glpi_status.dart';
import 'app_colors.dart';

enum AppStatusTone { brand, info, success, warning, danger, neutral }

class AppStatusVisuals {
  final Color background;
  final Color foreground;
  final Color surface;

  const AppStatusVisuals({
    required this.background,
    required this.foreground,
    required this.surface,
  });
}

class AppStatusPalette {
  static AppStatusTone fromGlpiStatus(dynamic rawStatus) {
    if (GlpiStatusMapper.isOffline(rawStatus)) {
      return AppStatusTone.danger;
    }

    final status = GlpiStatusMapper.tryParse(rawStatus);
    switch (status) {
      case GlpiStatus.novo:
        return AppStatusTone.brand;
      case GlpiStatus.emAtendimento:
      case GlpiStatus.planejado:
        return AppStatusTone.info;
      case GlpiStatus.pendente:
        return AppStatusTone.warning;
      case GlpiStatus.solucionado:
        return AppStatusTone.success;
      case GlpiStatus.fechado:
        return AppStatusTone.neutral;
      case null:
        return AppStatusTone.neutral;
    }
  }

  static AppStatusVisuals resolve(AppStatusTone tone) {
    switch (tone) {
      case AppStatusTone.brand:
        return const AppStatusVisuals(
          background: AppColors.brandSoft,
          foreground: AppColors.brandDark,
          surface: AppColors.brandSoft,
        );
      case AppStatusTone.info:
        return const AppStatusVisuals(
          background: AppColors.infoSoft,
          foreground: AppColors.info,
          surface: AppColors.infoSoft,
        );
      case AppStatusTone.success:
        return const AppStatusVisuals(
          background: AppColors.successSoft,
          foreground: AppColors.success,
          surface: AppColors.successSoft,
        );
      case AppStatusTone.warning:
        return const AppStatusVisuals(
          background: AppColors.warningSoft,
          foreground: AppColors.warning,
          surface: AppColors.warningSoft,
        );
      case AppStatusTone.danger:
        return const AppStatusVisuals(
          background: AppColors.dangerSoft,
          foreground: AppColors.danger,
          surface: AppColors.dangerSoft,
        );
      case AppStatusTone.neutral:
        return const AppStatusVisuals(
          background: AppColors.neutralSoft,
          foreground: AppColors.neutral,
          surface: AppColors.neutralSoft,
        );
    }
  }
}
