# Momentum App - Data Format Documentation

## Overview
The Momentum app uses JSON format for data export and import. All data is stored locally using SharedPreferences and can be exported/imported through the Settings screen.

## Data Structure

### Complete Export File Format
```json
{
  "checkIns": {
    "yyyy-MM-dd": {
      "date": "yyyy-MM-dd",
      "activityType": "string or null",
      "timestamp": "ISO 8601 datetime string"
    }
  },
  "activityTypes": ["string", "string", ...],
  "exportedAt": "ISO 8601 datetime string"
}
```

### Example Export File
```json
{
  "checkIns": {
    "2025-01-01": {
      "date": "2025-01-01",
      "activityType": "Gym",
      "timestamp": "2025-01-01T08:30:00.000Z"
    },
    "2025-01-02": {
      "date": "2025-01-02",
      "activityType": "Run",
      "timestamp": "2025-01-02T07:15:00.000Z"
    },
    "2025-01-03": {
      "date": "2025-01-03",
      "activityType": null,
      "timestamp": "2025-01-03T09:00:00.000Z"
    }
  },
  "activityTypes": [
    "Run",
    "Yoga",
    "Gym",
    "Walk",
    "Bike"
  ],
  "exportedAt": "2025-01-05T12:00:00.000Z"
}
```

## Field Descriptions

### CheckInData Object
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `checkIns` | Object | Yes | Map of date strings to DayCheckIn objects |
| `activityTypes` | Array<String> | Yes | List of user's custom activity types |
| `exportedAt` | String | No | ISO 8601 timestamp of when data was exported |

### DayCheckIn Object
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | String | Yes | Date in `yyyy-MM-dd` format (e.g., "2025-01-01") |
| `activityType` | String or null | No | The type of activity done that day. `null` means day was checked in without activity |
| `timestamp` | String | Yes | ISO 8601 datetime when check-in was created |

### Activity Types
- Default activity types: `["Run", "Yoga", "Gym", "Walk", "Bike"]`
- Users can add custom activity types through Settings
- Activity types are case-sensitive
- Empty array is valid but defaults will be restored on import

## Date Format
- **Check-in dates**: `yyyy-MM-dd` (e.g., "2025-01-01")
- **Timestamps**: ISO 8601 format (e.g., "2025-01-01T08:30:00.000Z")

## Import/Export Process

### Exporting Data

The export function works across all platforms:

**Web (Chrome, Firefox, Safari, Edge):**
1. Go to Settings screen
2. Tap "Export Data"
3. Browser download dialog appears
4. File `momentum-backup-{date}.json` is downloaded to your Downloads folder

**Mobile (iOS/Android):**
1. Go to Settings screen
2. Tap "Export Data"
3. File is created in app documents directory
4. Share sheet opens - choose where to save (Files app, Drive, Dropbox, etc.)

**Desktop (Windows/macOS/Linux):**
1. Go to Settings screen
2. Tap "Export Data"
3. File is created in app documents directory
4. Share/save dialog appears to choose destination

### Importing Data
1. Go to Settings screen
2. Tap "Import Data"
3. Select a valid JSON file with the format above
4. Data is validated and loaded
5. Success/failure message is shown

### Data Validation
The import process validates:
- Valid JSON structure
- Required fields present
- Correct date format (`yyyy-MM-dd`)
- Valid ISO 8601 timestamps
- Activity types is an array of strings

## Implementation Details

### Storage Service
- **Location**: `lib/core/services/storage_service.dart`
- **Methods**:
  - `exportData()` - Creates JSON backup file and shares it
  - `importData(String filePath)` - Imports data from JSON file
  - `resetData()` - Clears all stored data

### Data Models
- **Location**: `lib/core/models/check_in_model.dart`
- **Classes**:
  - `DayCheckIn` - Single day's check-in
  - `CheckInData` - Complete export/import data structure
  - `StreakStats` - Calculated statistics (not persisted)

### JSON Serialization
- Uses `json_annotation` package
- Generated code in `check_in_model.g.dart`
- Automatically handles serialization/deserialization

## Example Use Cases

### Creating a Manual Backup File
```json
{
  "checkIns": {
    "2025-01-01": {
      "date": "2025-01-01",
      "activityType": "Gym",
      "timestamp": "2025-01-01T10:00:00.000Z"
    }
  },
  "activityTypes": ["Gym", "Run"],
  "exportedAt": "2025-01-05T12:00:00.000Z"
}
```

### Importing from Another Device
1. Export data from Device A
2. Transfer JSON file to Device B (email, cloud storage, etc.)
3. On Device B, go to Settings > Import Data
4. Select the transferred JSON file
5. Data from Device A is now on Device B

### Resetting to Fresh Start
1. Go to Settings
2. Tap "Reset All Data"
3. Confirm the action
4. All check-ins and custom activity types are deleted
5. Default activity types are restored

## Notes
- All dates are stored in UTC timezone
- The app uses local-first architecture - all data is stored on device
- Export files can be manually edited (ensure valid JSON format)
- Invalid import files will show an error and not modify existing data
- Activity types persist across check-ins - deleting an activity type doesn't delete check-ins with that type
