// Web-specific file download implementation
import 'dart:convert';
// hack: services uses conditional import to prevent Mobile/Desktop issues
import 'dart:html' as html;

/// Download file on web platform
void downloadFile(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create anchor element and trigger download
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  // Clean up the blob URL
  html.Url.revokeObjectUrl(url);
}
