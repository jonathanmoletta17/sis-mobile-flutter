import 'dart:typed_data';

import 'attachment_open_result.dart';
import 'platform_attachment_opener_stub.dart'
    if (dart.library.io) 'platform_attachment_opener_io.dart'
    if (dart.library.html) 'platform_attachment_opener_web.dart'
    as platform_opener;

Future<AttachmentOpenResult> openAttachmentBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
}) {
  return platform_opener.openAttachmentBytes(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
