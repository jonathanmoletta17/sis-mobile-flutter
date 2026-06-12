import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class SearchableSelectField extends StatefulWidget {
  final String label;
  final List<String> items;
  final bool isRequired;
  final String? initialValue;
  final String hintText;
  final String searchLabel;
  final void Function(String?) onChanged;

  const SearchableSelectField({
    super.key,
    required this.label,
    required this.items,
    this.isRequired = false,
    this.initialValue,
    this.hintText = 'Buscar',
    this.searchLabel = 'Filtrar opções',
    required this.onChanged,
  });

  @override
  State<SearchableSelectField> createState() => _SearchableSelectFieldState();
}

class _SearchableSelectFieldState extends State<SearchableSelectField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SearchableSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  Future<void> _openPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalizedFilter = filter.trim().toLowerCase();
            final effectiveItems = widget.items
                .where((item) => item != '---')
                .where(
                  (item) =>
                      normalizedFilter.isEmpty ||
                      item.toLowerCase().contains(normalizedFilter),
                )
                .toList(growable: false);

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: widget.searchLabel,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() => filter = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: effectiveItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              child: Text(
                                'Nenhuma opção encontrada',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            )
                          : Scrollbar(
                              thumbVisibility: true,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: effectiveItems.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = effectiveItems[index];
                                  return ListTile(
                                    title: Text(item),
                                    selected: item == _selectedValue,
                                    onTap: () =>
                                        Navigator.of(context).pop(item),
                                  );
                                },
                              ),
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

    if (!mounted || selected == null) return;
    setState(() => _selectedValue = selected);
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;
    final selectedText = _selectedValue?.trim();
    final hasSelection = selectedText != null && selectedText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: FormField<String>(
        initialValue: _selectedValue,
        validator: (_) {
          if (widget.isRequired && !hasSelection) return 'Campo obrigatorio';
          return null;
        },
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.textStrong),
              ),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: _openPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    errorText: field.errorText,
                    suffixIcon: const Icon(Icons.search),
                  ),
                  child: Text(
                    hasSelection ? selectedText : widget.hintText,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: hasSelection
                          ? AppColors.textStrong
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selecione uma localização',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}
