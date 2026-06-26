import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<Uint8List?> readPlatformFileBytes(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) return bytes;

  final stream = file.readStream;
  if (stream == null) return null;

  final builder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
