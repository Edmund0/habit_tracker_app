import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Download file on web platform using modern web APIs
void downloadFile(String content, String fileName) {
  final bytes = utf8.encode(content);

  // Create blob from content
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );

  // Create object URL from blob
  final url = web.URL.createObjectURL(blob);

  // Create anchor element and trigger download
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();

  // Clean up the blob URL
  web.URL.revokeObjectURL(url);
}
