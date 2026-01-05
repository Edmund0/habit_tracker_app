import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/check_in_provider.dart';

/// Activity selector modal - appears AFTER check-in
/// Implements PRD R3.0: Post-Check-in Flow (don't block primary action)
class ActivitySelectorModal extends ConsumerWidget {
  final DateTime date;

  const ActivitySelectorModal({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityTypes = ref.watch(activityTypesProvider);
    final isCheckedIn = ref.watch(checkInsProvider.notifier).isCheckedIn(date);
    final currentActivity = ref.watch(checkInsProvider.notifier).getActivityType(date);

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
              if (isCheckedIn)
                IconButton(
                  onPressed: () {
                    ref.read(checkInsProvider.notifier).toggleCheckIn(date);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.red,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.zinc700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
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
                          await ref.read(checkInsProvider.notifier).toggleCheckIn(date);
                        }
                        // Update activity type
                        ref.read(checkInsProvider.notifier).updateActivityType(
                          date,
                          isSelected ? null : activity,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
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
