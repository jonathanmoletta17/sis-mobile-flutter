import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_status.dart';

class SisStatusChip extends StatelessWidget {
  final String label;
  final AppStatusTone tone;

  const SisStatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = AppStatusPalette.resolve(tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: visuals.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: visuals.foreground,
        ),
      ),
    );
  }
}
