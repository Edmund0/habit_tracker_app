// Stub implementation for non-web platforms
// This file is never actually used on mobile/desktop, but needed for compilation

/// Download file (stub for non-web platforms)
void downloadFile(String content, String fileName) {
  throw UnsupportedError('File download is not supported on this platform');
}
