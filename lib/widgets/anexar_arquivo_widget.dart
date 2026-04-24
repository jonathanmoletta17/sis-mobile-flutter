import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AnexarArquivoWidget extends StatefulWidget {
  final ValueChanged<List<PlatformFile>> onFilesSelected;

  const AnexarArquivoWidget({super.key, required this.onFilesSelected});

  @override
  State<AnexarArquivoWidget> createState() => _AnexarArquivoWidgetState();
}

class _AnexarArquivoWidgetState extends State<AnexarArquivoWidget> {
  final List<PlatformFile> _arquivosSelecionados = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _selecionarArquivos() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
      withData: true,
    );

    if (!mounted) return;

    if (resultado != null && resultado.files.isNotEmpty) {
      setState(() {
        for (final arquivo in resultado.files) {
          final alreadyExists = _arquivosSelecionados.any((existente) {
            final existingPath = existente.path ?? '';
            final selectedPath = arquivo.path ?? '';
            return existente.name == arquivo.name &&
                existingPath == selectedPath;
          });

          if (!alreadyExists) {
            _arquivosSelecionados.add(arquivo);
          }
        }
      });

      widget.onFilesSelected(List<PlatformFile>.from(_arquivosSelecionados));
    }
  }

  Future<void> _tirarFoto() async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) return;

    try {
      final file = File(foto.path);
      final size = await file.length();

      final arquivoFoto = PlatformFile(
        name: foto.name,
        path: foto.path,
        size: size,
        bytes: null,
      );

      if (!mounted) return;

      setState(() {
        final alreadyExists = _arquivosSelecionados.any((existente) {
          final existingPath = existente.path ?? '';
          final selectedPath = arquivoFoto.path ?? '';
          return existente.name == arquivoFoto.name &&
              existingPath == selectedPath;
        });

        if (!alreadyExists) {
          _arquivosSelecionados.add(arquivoFoto);
        }
      });

      widget.onFilesSelected(List<PlatformFile>.from(_arquivosSelecionados));
    } catch (e) {
      debugPrint('Erro ao processar foto: $e');
    }
  }

  void _removerArquivo(int index) {
    setState(() {
      _arquivosSelecionados.removeAt(index);
    });
    widget.onFilesSelected(List<PlatformFile>.from(_arquivosSelecionados));
  }

  void _limparTudo() {
    setState(() {
      _arquivosSelecionados.clear();
    });
    widget.onFilesSelected([]);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anexar arquivo',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.textStrong),
              ),
              if (_arquivosSelecionados.isNotEmpty)
                TextButton(onPressed: _limparTudo, child: const Text('Limpar')),
            ],
          ),
          Text(
            'Se necessario, anexe arquivos aqui ou tire fotos.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: _tirarFoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.surfaceMuted,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selecionarArquivos,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _arquivosSelecionados.isNotEmpty
                            ? AppColors.brand
                            : AppColors.border,
                        width: _arquivosSelecionados.isNotEmpty ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      color: AppColors.surfaceMuted,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Clique para selecionar arquivo(s)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.attach_file,
                          color: _arquivosSelecionados.isNotEmpty
                              ? AppColors.brand
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_arquivosSelecionados.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.brand,
                ),
                const SizedBox(width: 6),
                Text(
                  'Arquivos selecionados: ${_arquivosSelecionados.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textStrong,
                  ),
                ),
              ],
            ),
          ],
          if (_arquivosSelecionados.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _arquivosSelecionados.length,
              itemBuilder: (context, index) {
                final arquivo = _arquivosSelecionados[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.brandSoft),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.brandSoft,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 18,
                        color: AppColors.brandDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${arquivo.name} - ${_formatFileSize(arquivo.size)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textStrong),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removerArquivo(index),
                        tooltip: 'Remover',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
