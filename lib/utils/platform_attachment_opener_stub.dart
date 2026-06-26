import 'dart:typed_data';

import 'attachment_open_result.dart';

Future<AttachmentOpenResult> openAttachmentBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
}) async {
  return const AttachmentOpenResult(
    success: false,
    message: 'Plataforma sem suporte para abertura de anexos.',
  );
}
