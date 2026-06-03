import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sis_mobile_flutter/widgets/anexar_arquivo_widget.dart';

void main() {
  testWidgets(
    'camera attachment persists selected photo bytes and notifies the form',
    (tester) async {
      final selectedFiles = <List<PlatformFile>>[];
      final photoBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnexarArquivoWidget(
              pickImageFromCamera: () async => XFile.fromData(
                photoBytes,
                name: 'camera-evidencia.jpg',
                mimeType: 'image/jpeg',
              ),
              onFilesSelected: (files) {
                selectedFiles.add(files);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();

      expect(selectedFiles, hasLength(1));
      expect(selectedFiles.single, hasLength(1));
      final file = selectedFiles.single.single;
      expect(file.name, isNotEmpty);
      expect(file.bytes, photoBytes);
      expect(file.size, photoBytes.length);
      expect(find.textContaining('Arquivos selecionados: 1'), findsOneWidget);
      expect(find.textContaining(file.name), findsOneWidget);
    },
  );
}
