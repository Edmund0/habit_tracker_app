import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/check_in_provider.dart';

/// Activity selector modal - appears AFTER check-in
/// Implements PRD R3.0: Post-Check-in Flow (don't block primary action)
class ActivitySelectorModal extends ConsumerStatefulWidget {
  final DateTime date;

  const ActivitySelectorModal({
    super.key,
    required this.date,
  });

  @override
  ConsumerState<ActivitySelectorModal> createState() => _ActivitySelectorModalState();
}

class _ActivitySelectorModalState extends ConsumerState<ActivitySelectorModal> {
  final TextEditingController _customActivityController = TextEditingController();

  @override
  void dispose() {
    _customActivityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityTypes = ref.watch(activityTypesProvider);
    // final isCheckedIn = ref.watch(checkInsProvider.notifier).isCheckedIn(widget.date);
    // final currentActivity = ref.watch(checkInsProvider.notifier).getActivityType(widget.date);

    final checkIns = ref.watch(checkInsProvider); // watch the state
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    final isCheckedIn = checkIns.containsKey(dateKey);
    final currentActivity = checkIns[dateKey]?.activityType;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.zinc800,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.zinc600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title and Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckedIn ? 'What did you do?' : 'Add Check-in',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.zinc100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCheckedIn
                          ? 'Optional - add context to your check-in'
                          : 'Log your activity for this day',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.zinc400,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button (only show if checked in)
              if (isCheckedIn)
                IconButton(
                  onPressed: () {
                    ref.read(checkInsProvider.notifier).toggleCheckIn(widget.date);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.red,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.zinc700,
                  ),
                ),
              // Close button (only show if not checked in)
              if (!isCheckedIn)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.zinc400,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.zinc700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Mark as Completed button (only show if not checked in)
          if (!isCheckedIn)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(checkInsProvider.notifier).toggleCheckIn(widget.date);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.electricLime,
                  foregroundColor: AppTheme.zinc900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mark as Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isCheckedIn) const SizedBox(height: 24),
          // Activity type section header
          if (isCheckedIn)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'ACTIVITY TYPE',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.zinc500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          // Activity options
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Activity type chips
                  ...activityTypes.map((activity) {
                    final isSelected = currentActivity == activity;
                    return _ActivityChip(
                      label: activity,
                      isSelected: isSelected,
                      onTap: () async {
                        // If not checked in, check in first
                        if (!isCheckedIn) {
                          await ref.read(checkInsProvider.notifier).toggleCheckIn(widget.date);
                        }
                        // If already selected, deselect it (don't close modal)
                        if (isSelected) {
                          ref.read(checkInsProvider.notifier).updateActivityType(
                            widget.date,
                            null,
                          );
                        } else {
                          // Select new activity and close modal
                          ref.read(checkInsProvider.notifier).updateActivityType(
                            widget.date,
                            activity,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    );
                  }),
                  // Skip/Close option
                  _ActivityChip(
                    label: isCheckedIn ? 'Skip' : 'Close',
                    isSelected: false,
                    isSkip: true,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Add custom activity section
          if (isCheckedIn)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.zinc700,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.zinc600),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customActivityController,
                      style: const TextStyle(color: AppTheme.zinc100),
                      decoration: const InputDecoration(
                        hintText: 'Add custom activity...',
                        hintStyle: TextStyle(color: AppTheme.zinc500),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (value) async {
                        if (value.trim().isNotEmpty) {
                          await ref.read(activityTypesProvider.notifier).addActivityType(value.trim());
                          _customActivityController.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final value = _customActivityController.text;
                      if (value.trim().isNotEmpty) {
                        await ref.read(activityTypesProvider.notifier).addActivityType(value.trim());
                        _customActivityController.clear();
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    color: AppTheme.electricLime,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.zinc800,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isSkip;
  final VoidCallback onTap;

  const _ActivityChip({
    required this.label,
    required this.isSelected,
    this.isSkip = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSkip
              ? Colors.transparent
              : isSelected
                  ? AppTheme.electricLime
                  : AppTheme.zinc700,
          border: Border.all(
            color: isSkip
                ? AppTheme.zinc600
                : isSelected
                    ? AppTheme.electricLime
                    : AppTheme.zinc600,
            width: isSkip ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppTheme.zinc900,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSkip
                    ? AppTheme.zinc400
                    : isSelected
                        ? AppTheme.zinc900
                        : AppTheme.zinc100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
