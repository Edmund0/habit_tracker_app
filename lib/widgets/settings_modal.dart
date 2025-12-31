
import 'package:flutter/material.dart';
import 'package:momentum/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


/// A modal bottom sheet that provides access to app settings.
///
/// This includes options for exporting data and resetting all data.
/// It uses the `DatabaseService` to perform these actions.
class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // A button to trigger the data export functionality.
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            onTap: () async {
              final json = db.exportData();
              final directory = await getApplicationDocumentsDirectory();
              final file = File('${directory.path}/momentum_data.json');
              await file.writeAsString(json);
              Share.shareXFiles([XFile(file.path)]);
            },
          ),
          // A button to reset all application data.
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('Reset Data', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              // Show a confirmation dialog before proceeding with the reset.
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Data?'),
                  content: const Text('This will permanently delete all your check-in history. This action cannot be undone.'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                      onPressed: () {
                        db.resetData();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Close the settings modal
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
