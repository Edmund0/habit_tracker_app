import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:momentum/old/modules/providers/habit_providers.dart';
import 'package:momentum/old/modules/widgets/stats_card.dart';
import 'package:momentum/old/modules/widgets/day_modal.dart';
import 'package:momentum/old/modules/widgets/settings_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final checkins = ref.watch(checkinsProvider);
    final streaks = ref.watch(streaksProvider);
    
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final todayCheckins = checkins[todayKey] ?? [];
    final todayProgress = habits.isNotEmpty
        ? ((todayCheckins.length / habits.length) * 100).round()
        : 0;

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMMM d').format(today),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
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
                const SizedBox(height: 32),
                // Today's Progress Card
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F2937), Color(0xFF374151)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF34D399).withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today\'s Progress',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$todayProgress%',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DayModal(date: today),
                                      );
                                    },
                                    icon: const Icon(
                                      LucideIcons.plus,
                                      size: 20,
                                    ),
                                    label: const Text('Check In'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return TweenAnimationBuilder<double>(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeOut,
                                      tween: Tween(
                                        begin: 0.0,
                                        end: todayProgress / 100,
                                      ),
                                      builder: (context, value, child) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            width: constraints.maxWidth * value,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF34D399),
                                                  Color(0xFF14B8A6),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${todayCheckins.length} of ${habits.length} activities completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Cards
                StatsCard(
                  type: StatsType.monthly,
                  value: streaks.monthly,
                  subtitle: 'Days in ${DateFormat('MMMM').format(today)}',
                ),
                const SizedBox(height: 16),
                StatsCard(
                  type: StatsType.yearly,
                  value: streaks.yearly.checkedDays,
                  percentage: streaks.yearly.percentage,
                  subtitle:
                      '${streaks.yearly.checkedDays} of ${streaks.yearly.totalDays} days this year',
                ),
                const SizedBox(height: 16),
                StatsCard(
                  type: StatsType.total,
                  value: streaks.total.streak,
                  subtitle: streaks.total.graceDayUsed
                      ? '1-day grace period active'
                      : 'Keep it going!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}