import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_theme.dart';

class WorkbenchSurface extends StatelessWidget {
  final Widget child;
  final bool centered;
  final bool fullBleed;
  final double maxWidth;

  const WorkbenchSurface({
    super.key,
    required this.child,
    this.centered = false,
    this.fullBleed = false,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final content = fullBleed
        ? child
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );

    final body = centered ? Center(child: content) : content;

    return Theme(
      data: AppTheme.build(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: fullBleed ? EdgeInsets.zero : const EdgeInsets.all(24),
            child: body,
          ),
        ),
      ),
    );
  }
}
