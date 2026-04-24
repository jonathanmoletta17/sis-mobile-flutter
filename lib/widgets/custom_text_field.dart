import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? helperText;
  final bool isRequired;
  final TextInputType keyboardType;
  final int maxLines;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.helperText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = isRequired ? '$label *' : label;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.textStrong),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                helperText!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: maxLines > 1 ? 14.0 : 16.0,
              ),
            ),
            maxLines: maxLines,
            validator: isRequired
                ? (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatorio'
                      : null
                : null,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
