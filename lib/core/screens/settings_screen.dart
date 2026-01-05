import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/check_in_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Settings screen for managing activity types and data
/// Implements PRD R3.1: Custom Activities and R6.0/R6.1: Data Export/Import
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addActivityType() {
    if (_textController.text.trim().isNotEmpty) {
      ref.read(activityTypesProvider.notifier).addActivityType(_textController.text);
      _textController.clear();
    }
  }

  Future<void> _handleImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final success = await StorageService.importData(result.files.single.path!);

      if (success && mounted) {
        await ref.read(checkInsProvider.notifier).reload();
        await ref.read(activityTypesProvider.notifier).reload();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data imported successfully'),
              backgroundColor: AppTheme.electricLime,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.zinc800,
        title: const Text(
          'Reset All Data?',
          style: TextStyle(color: AppTheme.zinc100),
        ),
        content: const Text(
          'This will permanently delete all your check-ins and activity types. This action cannot be undone.',
          style: TextStyle(color: AppTheme.zinc300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageService.resetData();
      await ref.read(checkInsProvider.notifier).reload();
      await ref.read(activityTypesProvider.notifier).reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset'),
            backgroundColor: AppTheme.electricLime,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityTypes = ref.watch(activityTypesProvider);

    return Scaffold(
      backgroundColor: AppTheme.zinc900,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.zinc900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Types Section
            const Text(
              'Activity Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.zinc100,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize your activity types for better tracking',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.zinc500,
              ),
            ),
            const SizedBox(height: 16),
            // Add activity input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _addActivityType(),
                    style: const TextStyle(color: AppTheme.zinc100),
                    decoration: const InputDecoration(
                      hintText: 'Add new activity...',
                      hintStyle: TextStyle(color: AppTheme.zinc500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _addActivityType,
                  icon: const Icon(Icons.add_rounded),
                  color: AppTheme.zinc900,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.electricLime,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Activity list
            if (activityTypes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No activity types yet. Add one above!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.zinc500,
                    ),
                  ),
                ),
              )
            else
              ...activityTypes.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.zinc700),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.zinc100,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(activityTypesProvider.notifier).removeActivityType(activity);
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: AppTheme.zinc500,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
            const Divider(color: AppTheme.zinc700),
            const SizedBox(height: 32),
            // Data Management Section
            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.zinc100,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Export, import, or reset your data',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.zinc500,
              ),
            ),
            const SizedBox(height: 16),
            // Export button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: StorageService.exportData,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Import button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleImport,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Import Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleReset,
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Reset All Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // App info
            const Center(
              child: Column(
                children: [
                  Text(
                    'Momentum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.zinc500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.zinc600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Friction kills habits."',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.zinc600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
