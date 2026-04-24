import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SisPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? bottom;
  final FloatingActionButton? floatingActionButton;

  const SisPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.drawer,
    this.bottom,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        titleSpacing: 20,
        title: subtitle == null
            ? Text(title)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textOnBrandMuted,
                    ),
                  ),
                ],
              ),
        actions: actions,
        bottom: bottom,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.background,
              AppColors.background,
            ],
            stops: [0, 0.18, 1],
          ),
        ),
        child: body,
      ),
    );
  }
}
