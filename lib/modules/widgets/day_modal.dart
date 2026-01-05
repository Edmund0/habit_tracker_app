import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:momentum/modules/providers/habit_providers.dart';

class DayModal extends ConsumerWidget {
  final DateTime date;

  const DayModal({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final checkins = ref.watch(checkinsProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayCheckins = checkins[dateKey] ?? [];
    
    final completionRate = habits.isNotEmpty
        ? ((dayCheckins.length / habits.length) * 100).round()
        : 0;

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
          constraints: const BoxConstraints(maxWidth: 400),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE').format(date),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d, yyyy').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
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
                    if (habits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    tween: Tween(
                                      begin: 0.0,
                                      end: completionRate / 100,
                                    ),
                                    builder: (context, value, child) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: constraints.maxWidth * value,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF34D399),
                                                Color(0xFF14B8A6),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$completionRate%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Habits list
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: habits.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 40,
                                color: Colors.grey.shade400.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No activities to track yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add some in settings!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: List.generate(
                            habits.length,
                            (index) {
                              final habit = habits[index];
                              final isChecked = dayCheckins.contains(habit);
                              
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 50 * index),
                                curve: Curves.easeOut,
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 10 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        ref
                                            .read(checkinsProvider.notifier)
                                            .toggleHabit(dateKey, habit);
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isChecked
                                              ? const Color(0xFF34D399).withOpacity(0.1)
                                              : Colors.grey.shade50,
                                          border: Border.all(
                                            color: isChecked
                                                ? const Color(0xFF34D399).withOpacity(0.3)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isChecked
                                                    ? const Color(0xFF34D399)
                                                    : Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: isChecked
                                                  ? const Icon(
                                                      LucideIcons.check,
                                                      color: Colors.white,
                                                      size: 16,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              habit,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isChecked
                                                    ? const Color(0xFF047857)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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