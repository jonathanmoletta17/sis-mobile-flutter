import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/widgets/anexar_arquivo_widget.dart';

// Nota: o fallback de recuperação via disco (_recoverBytesFromDisk, quando o
// picker devolve bytes nulos mas path válido) não tem teste automatizado
// aqui — File.readAsBytes() real dentro de testWidgets trava de forma
// consistente neste ambiente (isolate de I/O do dart:io nunca responde,
// mesmo com tester.runAsync; um script dart standalone equivalente funciona
// normalmente, então é um problema do ambiente de teste, não do código). A
// lógica em si é uma chamada trivial de um linha, já validada em produção
// pelo mesmo padrão em form_template.dart (_normalizeSelectedFiles).

void main() {
  testWidgets(
    'arquivo com bytes já populados pelo picker é aceito como está',
    (tester) async {
      final selectedFiles = <List<PlatformFile>>[];
      final bytes = Uint8List.fromList(<int>[10, 20, 30]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnexarArquivoWidget(
              pickFiles: () async => FilePickerResult([
                PlatformFile(
                  name: 'evidencia.pdf',
                  size: bytes.length,
                  bytes: bytes,
                ),
              ]),
              onFilesSelected: (files) => selectedFiles.add(files),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(selectedFiles, hasLength(1));
      expect(selectedFiles.single.single.bytes, bytes);
      expect(find.textContaining('Arquivos selecionados: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'arquivo sem bytes e sem path recuperável é rejeitado com aviso, '
    'sem entrar na lista de selecionados',
    (tester) async {
      final selectedFiles = <List<PlatformFile>>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnexarArquivoWidget(
              pickFiles: () async => FilePickerResult([
                PlatformFile(name: 'irrecuperavel.jpg', size: 999),
              ]),
              onFilesSelected: (files) => selectedFiles.add(files),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(selectedFiles, isEmpty);
      expect(find.textContaining('Arquivos selecionados'), findsNothing);
      expect(
        find.textContaining('Não foi possível ler o arquivo'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'lote misto: arquivo válido entra na lista, irrecuperável só gera aviso',
    (tester) async {
      final selectedFiles = <List<PlatformFile>>[];
      final bytes = Uint8List.fromList(<int>[9, 9, 9]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnexarArquivoWidget(
              pickFiles: () async => FilePickerResult([
                PlatformFile(name: 'valido.pdf', size: 3, bytes: bytes),
                PlatformFile(name: 'quebrado.jpg', size: 999),
              ]),
              onFilesSelected: (files) => selectedFiles.add(files),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(selectedFiles, hasLength(1));
      expect(selectedFiles.single, hasLength(1));
      expect(selectedFiles.single.single.name, 'valido.pdf');
      expect(find.textContaining('Arquivos selecionados: 1'), findsOneWidget);
      expect(
        find.textContaining('Não foi possível ler o arquivo'),
        findsOneWidget,
      );
    },
  );
}
