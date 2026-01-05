import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum StatsType { monthly, yearly, total }

class StatsCard extends StatelessWidget {
  final StatsType type;
  final int value;
  final String? subtitle;
  final int? percentage;

  const StatsCard({
    super.key,
    required this.type,
    required this.value,
    this.subtitle,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
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
      child: Stack(
        children: [
          // Glow effect
          Container(
            decoration: BoxDecoration(
              color: config.bgGlow,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: config.bgGlow,
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Main card
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade200.withOpacity(0.5),
              ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: config.gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        config.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (percentage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'days',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  config.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatsConfig _getConfig() {
    switch (type) {
      case StatsType.monthly:
        return _StatsConfig(
          icon: LucideIcons.calendar,
          gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
          ),
          bgGlow: const Color(0xFF34D399).withOpacity(0.1),
          label: 'Monthly Streak',
        );
      case StatsType.yearly:
        return _StatsConfig(
          icon: LucideIcons.flame,
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
          ),
          bgGlow: const Color(0xFFFBBF24).withOpacity(0.1),
          label: 'Yearly Progress',
        );
      case StatsType.total:
        return _StatsConfig(
          icon: LucideIcons.trophy,
          gradient: const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFA855F7)],
          ),
          bgGlow: const Color(0xFFA78BFA).withOpacity(0.1),
          label: 'Total Streak',
        );
    }
  }
}

class _StatsConfig {
  final IconData icon;
  final Gradient gradient;
  final Color bgGlow;
  final String label;

  _StatsConfig({
    required this.icon,
    required this.gradient,
    required this.bgGlow,
    required this.label,
  });
}