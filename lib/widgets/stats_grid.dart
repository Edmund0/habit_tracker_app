
import 'package:flutter/material.dart';
import 'package:momentum/services/database_service.dart';
import 'package:provider/provider.dart';

/// A widget that displays a grid of key statistics.
///
/// This widget is used on the `CheckInPage` to show the user's progress
/// at a glance. It includes metrics like the current streak, monthly count,
/// and yearly consistency percentage.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // The Consumer widget rebuilds this grid whenever the database notifies listeners.
    return Consumer<DatabaseService>(
      builder: (context, db, child) {
        // Fetching the calculated stats from the database service.
        final streak = db.getStreak();
        final monthlyCheckIns = db.getMonthlyCheckIns();
        final yearlyConsistency = db.getYearlyConsistency();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // A reusable widget for each individual stat.
              _StatTile(
                label: 'Streak',
                value: streak.toString(),
              ),
              _StatTile(
                label: 'This Month',
                value: monthlyCheckIns.toString(),
              ),
              _StatTile(
                label: 'Yearly',
                // Displaying the consistency as a percentage.
                value: '${(yearlyConsistency * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A private helper widget to display a single statistic.
///
/// This keeps the main `StatsGrid` build method clean and readable.
class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
