import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/platform_file_bytes.dart';

void main() {
  test('readPlatformFileBytes returns direct bytes when available', () async {
    final file = PlatformFile(
      name: 'evidencia.txt',
      size: 3,
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(await readPlatformFileBytes(file), [1, 2, 3]);
  });

  test(
    'readPlatformFileBytes collects read stream when bytes are absent',
    () async {
      final file = PlatformFile(
        name: 'evidencia.pdf',
        size: 5,
        readStream: Stream<List<int>>.fromIterable([
          [1, 2],
          [3, 4, 5],
        ]),
      );

      expect(await readPlatformFileBytes(file), [1, 2, 3, 4, 5]);
    },
  );

  test(
    'readPlatformFileBytes returns null when no bytes or stream exist',
    () async {
      final file = PlatformFile(name: 'sem-bytes.txt', size: 0);

      expect(await readPlatformFileBytes(file), isNull);
    },
  );
}
