import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Large central Orb button for one-tap check-in
/// Implements PRD R1.1: One-Tap Check-in with haptic feedback
class OrbButton extends StatefulWidget {
  final bool isCheckedIn;
  final VoidCallback onTap;

  const OrbButton({
    super.key,
    required this.isCheckedIn,
    required this.onTap,
  });

  @override
  State<OrbButton> createState() => _OrbButtonState();
}

class _OrbButtonState extends State<OrbButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback (PRD R1.1)
    HapticFeedback.mediumImpact();

    // Animation
    _controller.forward().then((_) => _controller.reverse());

    // Execute callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isCheckedIn
                        ? AppTheme.electricLime.withOpacity(0.4)
                        : AppTheme.zinc700.withOpacity(0.2),
                    blurRadius: 40 * _pulseAnimation.value,
                    spreadRadius: 10 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isCheckedIn
                            ? AppTheme.electricLime
                            : AppTheme.zinc700,
                        width: 3,
                      ),
                    ),
                  ),
                  // Inner filled circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isCheckedIn
                          ? AppTheme.electricLime
                          : AppTheme.zinc800,
                      gradient: widget.isCheckedIn
                          ? RadialGradient(
                              colors: [
                                AppTheme.electricLime,
                                AppTheme.electricLimeDark,
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isCheckedIn
                              ? Icons.check_rounded
                              : Icons.show_chart_rounded,
                          size: 60,
                          color: widget.isCheckedIn
                              ? AppTheme.zinc900
                              : AppTheme.zinc600,
                        ),
                        if (!widget.isCheckedIn) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'TAP TO LOG',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.zinc600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Pulsing ring when not checked in
                  if (!widget.isCheckedIn)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: 1.0 - value,
                          child: Container(
                            width: 170 + (30 * value),
                            height: 170 + (30 * value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.electricLime.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted && !widget.isCheckedIn) {
                          setState(() {});
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
