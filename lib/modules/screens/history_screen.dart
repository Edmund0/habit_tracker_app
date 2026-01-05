import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:momentum/modules/providers/habit_providers.dart';
import 'package:momentum/modules/widgets/calendar_view.dart';
import 'package:momentum/modules/widgets/day_modal.dart';
import 'package:momentum/modules/widgets/settings_modal.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  Map<String, int> _getMonthStats() {
    final habits = ref.read(habitsProvider);
    final checkins = ref.read(checkinsProvider);
    final monthKey = DateFormat('yyyy-MM').format(_currentMonth);
    
    int totalDays = 0;
    int completedDays = 0;

    checkins.forEach((dateKey, activities) {
      if (dateKey.startsWith(monthKey) && activities.isNotEmpty) {
        totalDays++;
        if (habits.isNotEmpty && activities.length == habits.length) {
          completedDays++;
        }
      }
    });

    return {'totalDays': totalDays, 'completedDays': completedDays};
  }

  List<MapEntry<String, List<String>>> _getRecentActivity() {
    final checkins = ref.read(checkinsProvider);
    final entries = checkins.entries.toList();
    entries.sort((a, b) => b.key.compareTo(a.key));
    return entries.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final checkins = ref.watch(checkinsProvider);
    final monthStats = _getMonthStats();
    final recentActivity = _getRecentActivity();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 100),
            child: Column(
              children: [
                // Header
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'History',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Your habit journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const SettingsModal(),
                          );
                        },
                        icon: Icon(
                          LucideIcons.settings,
                          color: Colors.grey.shade600,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Month Summary
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF9333EA)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('MMMM yyyy').format(_currentMonth)} Summary',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFDDD6FE),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${monthStats['totalDays']}',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Active days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFDDD6FE),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${monthStats['completedDays']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Perfect days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFDDD6FE),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Calendar
                CalendarView(
                  currentMonth: _currentMonth,
                  onMonthChanged: (month) {
                    setState(() {
                      _currentMonth = month;
                    });
                  },
                  checkins: checkins,
                  habits: habits,
                  onDayClick: (date) {
                    showDialog(
                      context: context,
                      builder: (context) => DayModal(date: date),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Recent Activity
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (recentActivity.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No activity yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        )
                      else
                        ...recentActivity.map((entry) {
                          final date = DateFormat('yyyy-MM-dd').parse(entry.key);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DayModal(date: date),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade100,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('EEEE, MMM d').format(date),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${entry.value.length} ${entry.value.length == 1 ? 'activity' : 'activities'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        LucideIcons.chevronRight,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}