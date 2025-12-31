
import 'package:flutter/material.dart';
import 'package:momentum/widgets/settings_modal.dart';
import 'package:provider/provider.dart';
import 'package:momentum/services/database_service.dart';
import 'package:momentum/widgets/stats_grid.dart';
import 'package:momentum/widgets/orb_button.dart';

/// The main check-in page of the application.
///
/// This page displays the user's current statistics (streak, monthly count, etc.)
/// and features a large central button (`OrbButton`) for daily check-ins.
/// It listens to `DatabaseService` to update its state in real-time.
class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
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
        // The Consumer widget listens for changes in DatabaseService and rebuilds
        // the UI tree below it. This is how the stats and check-in button update.
        builder: (context, db, child) {
          final today = DateTime.now();
          final isCheckedIn = db.isCheckedIn(today);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // A grid displaying the key performance statistics.
              const StatsGrid(),
              const Spacer(),
              // The main check-in button.
              OrbButton(
                isCheckedIn: isCheckedIn,
                onTap: () {
                  // When tapped, it toggles the check-in status for today.
                  // The Consumer will then trigger a rebuild to reflect the change.
                  db.toggleDate(today);
                },
              ),
              const Spacer(),
              // A flex factor of 2 gives the bottom spacer more room.
              const Flexible(child: SizedBox(), flex: 2),
            ],
          );
        },
      ),
    );
  }
}
