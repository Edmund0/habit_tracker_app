// Web-specific file download implementation
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Download file on web platform
void downloadFile(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
