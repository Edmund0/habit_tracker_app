import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momentum/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsModalIO extends StatelessWidget {
  const SettingsModalIO({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          /// Export (Filesystem-based)
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            onTap: () async {
              final json = db.exportData();

              final directory =
                  await getApplicationDocumentsDirectory();
              final file =
                  File('${directory.path}/momentum_data.json');

              await file.writeAsString(json);

              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Momentum check-in data',
              );
            },
          ),

          /// Reset
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text(
              'Reset Data',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              _confirmReset(context, db);
            },
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, DatabaseService db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data?'),
        content: const Text(
          'This will permanently delete all your check-in history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              db.resetData();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
