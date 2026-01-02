import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momentum/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsModalWeb extends StatelessWidget {
  const SettingsModalWeb({super.key});

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

          /// Export (Web-safe)
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Copies JSON to clipboard'),
            onTap: () async {
              final json = db.exportData();

              await Clipboard.setData(ClipboardData(text: json));

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exported data copied to clipboard'),
                  ),
                );
              }
            },
          ),

          /// Optional: Share JSON as text (browser share sheet)
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Data'),
            onTap: () {
              final json = db.exportData();
              Share.share(json);
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
