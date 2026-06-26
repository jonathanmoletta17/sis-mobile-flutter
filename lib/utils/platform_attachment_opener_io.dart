import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'attachment_open_result.dart';
import 'attachment_opening_policy.dart';

Future<AttachmentOpenResult> openAttachmentBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
}) async {
  final safeFileName = AttachmentOpeningPolicy.safeFilename(filename);
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}${Platform.pathSeparator}$safeFileName');
  await file.writeAsBytes(bytes, flush: true);

  final result = await OpenFilex.open(file.path);
  return AttachmentOpenResult(
    success: result.type == ResultType.done,
    message: result.message,
  );
}
