import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../models/dtic_formcreator_models.dart';

class DticSearchableSelectField extends StatefulWidget {
  const DticSearchableSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.required,
    required this.onChanged,
    this.value,
  });

  final String label;
  final List<DticFormOption> options;
  final bool required;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<DticSearchableSelectField> createState() =>
      _DticSearchableSelectFieldState();
}

class _DticSearchableSelectFieldState extends State<DticSearchableSelectField> {
  String _filter = '';

  Future<void> _openPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = widget.options.where((option) {
              if (_filter.trim().isEmpty) return true;
              return option.label.toLowerCase().contains(_filter.toLowerCase());
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar opcoes',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() => _filter = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(option.label),
                            onTap: () =>
                                Navigator.of(context).pop(option.value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    widget.onChanged(selected);
    setState(() => _filter = '');
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = widget.options
        .where((option) => option.value == widget.value)
        .map((option) => option.label)
        .cast<String?>()
        .firstWhere((label) => label != null, orElse: () => widget.value);

    return FormField<String>(
      initialValue: widget.value,
      validator: (_) {
        if (widget.required &&
            (widget.value == null || widget.value!.isEmpty)) {
          return 'Campo obrigatorio.';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: _openPicker,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.required
                      ? '${widget.label} *'
                      : widget.label,
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  selectedLabel == null || selectedLabel.isEmpty
                      ? 'Selecionar'
                      : selectedLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selectedLabel == null || selectedLabel.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textStrong,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
