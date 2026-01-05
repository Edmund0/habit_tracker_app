import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/check_in_model.dart';
import '../theme/app_theme.dart';

/// Bento-style stats grid
/// Implements PRD R2.1: Dashboard showing Streak, Monthly Count, and Yearly Consistency %
class BentoStatsGrid extends StatelessWidget {
  final StreakStats stats;

  const BentoStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Column(
      children: [
        // Current Streak Card (Large)
        _StatCard(
          title: 'Current Streak',
          value: stats.currentStreak.toString(),
          unit: 'days',
          subtitle: stats.graceDayUsed
              ? '1-day grace period active'
              : 'Keep it going!',
          gradientColors: const [AppTheme.electricLime, AppTheme.electricLimeDark],
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 16),
        // Monthly and Yearly Stats (2 columns)
        Row(
          children: [
            // Monthly Count
            Expanded(
              child: _StatCard(
                title: 'This Month',
                value: stats.monthlyCount.toString(),
                unit: 'days',
                subtitle: DateFormat('MMMM').format(today),
                gradientColors: const [AppTheme.zinc700, AppTheme.zinc600],
                icon: Icons.calendar_month_rounded,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 16),
            // Yearly Percentage
            Expanded(
              child: _StatCard(
                title: 'This Year',
                value: '${stats.yearlyPercentage}%',
                unit: '',
                subtitle: '${stats.yearlyCount} days',
                gradientColors: const [AppTheme.zinc700, AppTheme.zinc600],
                icon: Icons.insights_rounded,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final bool isCompact;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.zinc600,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  color: gradientColors[0] == AppTheme.electricLime
                      ? AppTheme.zinc900
                      : AppTheme.zinc300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                icon,
                size: isCompact ? 20 : 24,
                color: gradientColors[0] == AppTheme.electricLime
                    ? AppTheme.zinc900.withOpacity(0.6)
                    : AppTheme.zinc400,
              ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isCompact ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: gradientColors[0] == AppTheme.electricLime
                      ? AppTheme.zinc900
                      : AppTheme.zinc100,
                  height: 1.0,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 16,
                      color: gradientColors[0] == AppTheme.electricLime
                          ? AppTheme.zinc900.withOpacity(0.7)
                          : AppTheme.zinc400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              color: gradientColors[0] == AppTheme.electricLime
                  ? AppTheme.zinc900.withOpacity(0.6)
                  : AppTheme.zinc500,
            ),
          ),
        ],
      ),
    );
  }
}
