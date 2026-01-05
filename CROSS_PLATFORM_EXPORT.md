# Cross-Platform Export/Import Implementation

## Overview
The Momentum app now supports data export and import across **all platforms**: Web, Mobile (iOS/Android), and Desktop (Windows/macOS/Linux).

## How It Works

### Platform Detection
The app uses Flutter's `kIsWeb` constant to detect the platform and apply the appropriate export method:

```dart
if (kIsWeb) {
  // Web: Browser download
  file_download.downloadFile(jsonString, fileName);
} else {
  // Mobile/Desktop: File sharing
  await Share.shareXFiles([XFile(file.path)]);
}
```

### Web Platform (Chrome, Firefox, Safari, Edge)
**Implementation**: Direct browser download using `dart:html`

**Files**:
- `lib/core/services/file_download_web.dart` - Web-specific download logic
- Uses `Blob` and `AnchorElement` to trigger browser download

**User Experience**:
1. Click "Export Data" in Settings
2. Browser's download dialog appears immediately
3. File is saved to Downloads folder
4. No additional steps required

**Technical Details**:
```dart
// Creates a downloadable blob and triggers browser download
final blob = html.Blob([bytes], 'application/json');
final url = html.Url.createObjectUrlFromBlob(blob);
final anchor = html.AnchorElement(href: url)
  ..setAttribute('download', fileName)
  ..click();
```

### Mobile Platforms (iOS & Android)
**Implementation**: File creation + native share sheet

**Packages Used**:
- `path_provider` - Get app documents directory
- `share_plus` - Native share functionality

**User Experience**:
1. Click "Export Data" in Settings
2. File is created in app's documents directory
3. Native share sheet appears
4. Choose destination (Files app, Google Drive, Dropbox, Email, etc.)

**Technical Details**:
```dart
final directory = await getApplicationDocumentsDirectory();
final file = File('${directory.path}/$fileName');
await file.writeAsString(jsonString);

await Share.shareXFiles(
  [XFile(file.path)],
  subject: 'Momentum Backup',
);
```

### Desktop Platforms (Windows, macOS, Linux)
**Implementation**: Same as mobile - file creation + share dialog

**User Experience**:
1. Click "Export Data" in Settings
2. File is created in app's documents directory
3. System dialog appears to choose save location
4. File is saved to chosen directory

**Platform-Specific Locations**:
- **Windows**: `C:\Users\{username}\Documents\Momentum\`
- **macOS**: `/Users/{username}/Documents/Momentum/`
- **Linux**: `/home/{username}/Documents/Momentum/`

## File Format
All platforms export the same JSON format:

```json
{
  "checkIns": {
    "2025-01-05": {
      "date": "2025-01-05",
      "activityType": "Gym",
      "timestamp": "2025-01-05T08:30:00.000Z"
    }
  },
  "activityTypes": ["Run", "Yoga", "Gym", "Walk", "Bike"],
  "exportedAt": "2025-01-05T12:00:00.000Z"
}
```

## Import Process (All Platforms)
The import process is consistent across platforms:

1. Use `file_picker` package to select JSON file
2. Read file contents
3. Parse and validate JSON
4. Import data to SharedPreferences
5. Reload app state
6. Show success/error message

**Platform Support**:
- ✅ Web - Select from filesystem/downloads
- ✅ iOS - Select from Files app or iCloud
- ✅ Android - Select from internal storage or cloud services
- ✅ Windows/macOS/Linux - Select from filesystem

## Conditional Imports
To avoid compilation errors with platform-specific code, the app uses conditional imports:

```dart
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as file_download;
```

**How it works**:
- On web builds: Imports `file_download_web.dart` (uses `dart:html`)
- On non-web builds: Imports `file_download_stub.dart` (throws error if called)
- Runtime check (`kIsWeb`) ensures correct code path is used

## Testing Checklist

### Web
- [ ] Export triggers browser download
- [ ] File has correct name format
- [ ] File contains valid JSON
- [ ] Import from downloaded file works
- [ ] Works in Chrome, Firefox, Safari, Edge

### iOS
- [ ] Export opens share sheet
- [ ] Can save to Files app
- [ ] Can save to iCloud Drive
- [ ] Can share via email/messages
- [ ] Import from Files app works

### Android
- [ ] Export opens share sheet
- [ ] Can save to device storage
- [ ] Can save to Google Drive
- [ ] Can share via apps
- [ ] Import from storage works

### Desktop (Windows/macOS/Linux)
- [ ] Export creates file in documents
- [ ] Share dialog appears
- [ ] File is readable
- [ ] Import works from any location

## Dependencies

### Required Packages
```yaml
dependencies:
  shared_preferences: ^2.0.15  # Local storage
  path_provider: ^2.0.11       # Get app directories
  share_plus: ^7.2.1           # Share functionality
  file_picker: ^6.1.1          # File selection for import
```

### Platform-Specific
- Web: Uses `dart:html` (built-in, no package needed)
- Mobile/Desktop: Uses standard Dart `dart:io`

## Error Handling

### Export Errors
- Web: If download fails, silently fails (browser blocks download)
- Mobile/Desktop: IOException if directory not accessible

### Import Errors
- Invalid JSON: Shows error message
- Missing required fields: Shows error message
- File read error: Shows error message

All errors are caught and shown to user via SnackBar.

## Future Improvements
- [ ] Add cloud sync (Google Drive, iCloud)
- [ ] Automatic backups
- [ ] Backup encryption
- [ ] Multiple export formats (CSV, PDF)
- [ ] Backup to email
- [ ] Schedule automatic exports

## Files Changed
1. `lib/core/services/storage_service.dart` - Main export/import logic
2. `lib/core/services/file_download_web.dart` - Web download implementation
3. `lib/core/services/file_download_stub.dart` - Stub for non-web platforms
4. `lib/core/screens/settings_screen.dart` - UI for export/import buttons

## Notes
- Export files are human-readable JSON (pretty-printed with 2-space indentation)
- File naming convention: `momentum-backup-YYYY-MM-DD.json`
- No size limits on export (all check-ins exported)
- Import overwrites existing data (user is warned)
- All timestamps in UTC timezone
