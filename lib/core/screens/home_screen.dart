import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/check_in_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/orb_button.dart';
import '../widgets/activity_selector_modal.dart';
import 'settings_screen.dart';

/// Main home screen - implements PRD minimalist check-in flow
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for reactive updates
    final checkIns = ref.watch(checkInsProvider);
    final stats = ref.watch(streakStatsProvider);
    final today = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(today);
    final isCheckedIn = checkIns.containsKey(dateKey);

    return Scaffold(
      backgroundColor: AppTheme.zinc900,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            child: Column(
              children: [
                // Header with date and settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(today),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.zinc500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM yyyy').format(today),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.zinc100,
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
                const SizedBox(height: 32),
                // Central Orb Button
                OrbButton(
                  isCheckedIn: isCheckedIn,
                  onTap: () async {
                    await ref.read(checkInsProvider.notifier).toggleCheckIn(today);
                  },
                ),
                // Add Activity Type Button (only when checked in)
                if (isCheckedIn) ...[
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => ActivitySelectorModal(date: today),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.zinc800,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppTheme.zinc700),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.electricLime,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppTheme.zinc900,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add Activity Type',
                            style: TextStyle(
                              color: AppTheme.zinc100,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: AppTheme.zinc500,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'OPTIONAL',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.zinc600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                // Stats Grid - 2x2 layout
                Row(
                  children: [
                    // Current Streak
                    Expanded(
                      child: _StatCard(
                        title: 'CURRENT\nSTREAK',
                        value: stats.currentStreak.toString(),
                        subtitle: 'Days in a row',
                      ),
                    ),
                    const SizedBox(width: 16),
                    // This Month
                    Expanded(
                      child: _StatCard(
                        title: 'THIS MONTH',
                        value: stats.monthlyCount.toString(),
                        subtitle: 'Total sessions',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Yearly Stats - Full width
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.zinc800,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.zinc700),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppTheme.zinc700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.zinc400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stats.yearlyCount} Workouts',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.zinc100,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'YEARLY TOTAL',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.zinc500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${stats.yearlyPercentage}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.electricLime,
                            ),
                          ),
                          const Text(
                            'CONSISTENCY',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.zinc500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.zinc800,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.zinc700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 28, // Fixed height for title area (fits 2 lines)
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.zinc500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppTheme.zinc100,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.zinc500,
            ),
          ),
        ],
      ),
    );
  }
}
