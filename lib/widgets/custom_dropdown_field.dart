import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final List<String> items;
  final bool isRequired;
  final String? initialValue;
  final void Function(String?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.isRequired = false,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;
    final effectiveItems = widget.items.where((item) => item != '---').toList();

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
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              hintText: widget.items.contains('---') ? '---' : 'Selecione',
            ),
            isExpanded: true,
            initialValue: effectiveItems.contains(_selectedValue)
                ? _selectedValue
                : null,
            items: effectiveItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            validator: widget.isRequired && _selectedValue == null
                ? (value) => 'Campo obrigatorio'
                : null,
          ),
        ],
      ),
    );
  }
}
