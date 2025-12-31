
import 'package:flutter/material.dart';
import 'package:momentum/services/database_service.dart';
import 'package:momentum/widgets/settings_modal.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// The history page, displaying a calendar view of the user's check-ins.
///
/// This page allows users to see their activity at a glance and also to
/// retroactively add or remove check-ins for any past day.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // The currently selected day in the calendar.
  DateTime _selectedDay = DateTime.now();
  // The day that the calendar is currently focused on (e.g., the current month).
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // The settings icon that opens the settings modal.
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const SettingsModal(),
              );
            },
          ),
        ],
      ),
      body: Consumer<DatabaseService>(
        // Listening to the DatabaseService to get the list of checked-in dates.
        builder: (context, db, child) {
          final checkedInDates = db.getCheckedInDates();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              // The first and last allowable days in the calendar.
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              // The currently selected day.
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              // Handling what happens when a day is tapped.
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update focused day as well
                });
                // Toggle the check-in status for the selected day.
                db.toggleDate(selectedDay);
              },
              // A function that returns a list of events for a given day.
              // In this case, it's just a dummy list to mark the day.
              eventLoader: (day) {
                if (checkedInDates.any((d) => isSameDay(d, day))) {
                  return ['Checked In'];
                }
                return [];
              },
              calendarBuilders: CalendarBuilders(
                // Custom builder for the markers below the day number.
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    // If the day has events (is checked in), display a green dot.
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
