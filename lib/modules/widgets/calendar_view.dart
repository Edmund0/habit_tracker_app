import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final Function(DateTime) onMonthChanged;
  final Map<String, List<String>> checkins;
  final List<String> habits;
  final Function(DateTime) onDayClick;

  const CalendarView({
    super.key,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.checkins,
    required this.habits,
    required this.onDayClick,
  });

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    // Get first day of the calendar grid (Sunday before monthStart)
    final calendarStart = monthStart.subtract(
      Duration(days: monthStart.weekday % 7),
    );
    
    // Get last day of the calendar grid
    final calendarEnd = monthEnd.add(
      Duration(days: 6 - monthEnd.weekday % 7),
    );
    
    final days = <DateTime>[];
    for (var day = calendarStart;
        day.isBefore(calendarEnd) || day.isAtSameMomentAs(calendarEnd);
        day = day.add(const Duration(days: 1))) {
      days.add(day);
    }

    return TweenAnimationBuilder<double>(
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(currentMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final newMonth = DateTime(
                          currentMonth.year,
                          currentMonth.month - 1,
                        );
                        onMonthChanged(newMonth);
                      },
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: Colors.grey.shade600,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final newMonth = DateTime(
                          currentMonth.year,
                          currentMonth.month + 1,
                        );
                        onMonthChanged(newMonth);
                      },
                      icon: Icon(
                        LucideIcons.chevronRight,
                        color: Colors.grey.shade600,
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
              ],
            ),
            const SizedBox(height: 24),
            // Weekday headers
            Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            ...List.generate((days.length / 7).ceil(), (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final index = weekIndex * 7 + dayIndex;
                    if (index >= days.length) {
                      return const Expanded(child: SizedBox());
                    }
                    
                    final day = days[index];
                    final isCurrentMonth = day.month == currentMonth.month;
                    final isToday = _isToday(day);
                    final completionLevel = _getCompletionLevel(day);
                    
                    return Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 10 * index),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onDayClick(day),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getBackgroundColor(
                                      completionLevel,
                                      isCurrentMonth,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday
                                        ? Border.all(
                                            color: const Color(0xFF34D399),
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('d').format(day),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _getTextColor(
                                          completionLevel,
                                          isCurrentMonth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 24),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: Colors.grey.shade100,
                  label: 'None',
                  hasBorder: true,
                ),
                const SizedBox(width: 16),
                const _LegendItem(
                  color: Color(0xFFD1FAE5),
                  label: 'Some',
                ),
                const SizedBox(width: 16),
                const _LegendItem(
                  color: Color(0xFF6EE7B7),
                  label: 'Most',
                ),
                const SizedBox(width: 16),
                const _LegendItem(
                  color: Color(0xFF34D399),
                  label: 'All',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getCompletionLevel(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayCheckins = checkins[dateKey] ?? [];
    
    if (habits.isEmpty || dayCheckins.isEmpty) return 0;
    return dayCheckins.length / habits.length;
  }

  Color _getBackgroundColor(double level, bool isCurrentMonth) {
    if (!isCurrentMonth) return Colors.transparent;
    if (level == 0) return Colors.grey.shade100;
    if (level < 0.33) return const Color(0xFFD1FAE5);
    if (level < 0.66) return const Color(0xFF6EE7B7);
    if (level < 1) return const Color(0xFF10B981);
    return const Color(0xFF34D399);
  }

  Color _getTextColor(double level, bool isCurrentMonth) {
    if (!isCurrentMonth) return Colors.grey.shade300;
    if (level >= 1) return Colors.white;
    return Colors.grey.shade700;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasBorder;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder
                ? Border.all(color: Colors.grey.shade200)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}