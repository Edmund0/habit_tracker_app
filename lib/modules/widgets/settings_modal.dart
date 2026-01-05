import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:momentum/modules/providers/habit_providers.dart';
import 'package:momentum/modules/services/local_storage_service.dart';

class SettingsModal extends ConsumerStatefulWidget {
  const SettingsModal({super.key});

  @override
  ConsumerState<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends ConsumerState<SettingsModal> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addHabit() {
    if (_textController.text.trim().isNotEmpty) {
      ref.read(habitsProvider.notifier).addHabit(_textController.text);
      _textController.clear();
    }
  }

  Future<void> _handleImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final success = await LocalStorageService.importData(result.files.single.path!);
      
      if (success && mounted) {
        await ref.read(habitsProvider.notifier).reload();
        await ref.read(checkinsProvider.notifier).reload();
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        LucideIcons.x,
                        color: Colors.grey.shade400,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activities section
                      Text(
                        'Your Activities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: (_) => _addHabit(),
                              decoration: InputDecoration(
                                hintText: 'Add new activity...',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF34D399)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addHabit,
                            icon: const Icon(LucideIcons.plus, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF34D399),
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (habits.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.sparkles,
                                  size: 32,
                                  color: Colors.grey.shade400.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No activities yet. Add one above!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...List.generate(habits.length, (index) {
                          final habit = habits[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 50 * index),
                            curve: Curves.easeOut,
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(-10 * (1 - value), 0),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      habit,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(habitsProvider.notifier)
                                            .removeHabit(habit);
                                      },
                                      icon: Icon(
                                        LucideIcons.trash2,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                      style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade100),
                      const SizedBox(height: 24),
                      // Data Management
                      Text(
                        'Data Management',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: LocalStorageService.exportData,
                              icon: const Icon(LucideIcons.download, size: 16),
                              label: const Text('Export'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleImport,
                              icon: const Icon(LucideIcons.upload, size: 16),
                              label: const Text('Import'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}