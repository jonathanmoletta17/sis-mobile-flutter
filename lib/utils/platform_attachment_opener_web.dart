// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'attachment_open_result.dart';
import 'attachment_opening_policy.dart';

Future<AttachmentOpenResult> openAttachmentBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
}) async {
  final safeFileName = AttachmentOpeningPolicy.safeFilename(filename);
  final resolvedMime = AttachmentOpeningPolicy.resolveMimeType(
    filename: safeFileName,
    mimeType: mimeType,
  );
  final blob = html.Blob([bytes], resolvedMime);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final openInline = AttachmentOpeningPolicy.shouldOpenInlineInBrowser(
    filename: safeFileName,
    mimeType: resolvedMime,
  );

  try {
    final anchor = html.AnchorElement(href: objectUrl)
      ..style.display = 'none'
      ..target = openInline ? '_blank' : '_self';
    if (!openInline) {
      anchor.download = safeFileName;
    }

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    Timer(const Duration(minutes: 1), () {
      html.Url.revokeObjectUrl(objectUrl);
    });

    return AttachmentOpenResult(
      success: true,
      message: openInline
          ? 'Arquivo enviado ao navegador.'
          : 'Download enviado ao navegador.',
    );
  } catch (error) {
    html.Url.revokeObjectUrl(objectUrl);
    return AttachmentOpenResult(success: false, message: error.toString());
  }
}
