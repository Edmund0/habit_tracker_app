import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/check_in_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_selector_modal.dart';
import 'settings_screen.dart';

/// History screen with calendar view
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final DateTime _today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final checkIns = ref.watch(checkInsProvider);
    final stats = ref.watch(streakStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.zinc900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            children: [
              // Header with date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_today),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.zinc100,
                        ),
                      ),
                      Text(
                        '${stats.monthlyCount} CHECK-INS',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.zinc500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_rounded),
                    color: AppTheme.zinc400,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.zinc800,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Month navigation with arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedDay),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.zinc100,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                        color: AppTheme.zinc300,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.zinc800,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                        color: AppTheme.zinc300,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.zinc800,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Calendar
              Container(
                  decoration: BoxDecoration(
                    color: AppTheme.zinc800,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.zinc700),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      // Show activity selector for the selected day
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => ActivitySelectorModal(date: selectedDay),
                      );
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      // Today
                      todayDecoration: BoxDecoration(
                        color: AppTheme.zinc700,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.electricLime,
                          width: 2,
                        ),
                      ),
                      todayTextStyle: const TextStyle(
                        color: AppTheme.zinc100,
                        fontWeight: FontWeight.bold,
                      ),
                      // Selected day
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.electricLime,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: AppTheme.zinc900,
                        fontWeight: FontWeight.bold,
                      ),
                      // Marked days (checked in)
                      markerDecoration: const BoxDecoration(
                        color: AppTheme.electricLime,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 1,
                      // Default days
                      defaultTextStyle: const TextStyle(
                        color: AppTheme.zinc100,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: AppTheme.zinc100,
                      ),
                      outsideTextStyle: const TextStyle(
                        color: AppTheme.zinc600,
                      ),
                      // Disable default decoration
                      defaultDecoration: const BoxDecoration(),
                      weekendDecoration: const BoxDecoration(),
                      outsideDecoration: const BoxDecoration(),
                    ),
                    headerVisible: false, // Hide the internal calendar header
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: AppTheme.zinc500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      weekendStyle: TextStyle(
                        color: AppTheme.zinc500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final dateKey = DateFormat('yyyy-MM-dd').format(day);
                        final isCheckedIn = checkIns.containsKey(dateKey);

                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isCheckedIn
                                ? AppTheme.electricLime
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isCheckedIn
                                    ? AppTheme.zinc900
                                    : AppTheme.zinc100,
                                fontWeight: isCheckedIn
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final dateKey = DateFormat('yyyy-MM-dd').format(day);
                        final isCheckedIn = checkIns.containsKey(dateKey);

                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isCheckedIn
                                ? AppTheme.electricLime
                                : AppTheme.zinc700,
                            shape: BoxShape.circle,
                            border: !isCheckedIn
                                ? Border.all(
                                    color: AppTheme.electricLime,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isCheckedIn
                                    ? AppTheme.zinc900
                                    : AppTheme.zinc100,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: AppTheme.zinc600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Legends
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Completed legend
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.electricLime,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.zinc400,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  // Missed legend
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.zinc600,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MISSED',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.zinc400,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
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
    );
  }
}
