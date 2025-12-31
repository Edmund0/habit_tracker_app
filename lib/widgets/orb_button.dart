
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A large, circular button that serves as the primary check-in interface.
///
/// This button changes color based on whether the day is checked in or not
/// and provides haptic feedback on tap. It's designed to be the focal
/// point of the `CheckInPage`.
class OrbButton extends StatelessWidget {
  // A boolean to determine the button's state (checked in or not).
  final bool isCheckedIn;
  // The callback function to execute when the button is tapped.
  final VoidCallback onTap;

  const OrbButton({super.key, required this.isCheckedIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Triggering a medium impact haptic feedback for a satisfying feel.
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // The color changes based on the check-in state.
          color: isCheckedIn ? Colors.green : Theme.of(context).colorScheme.primary,
          // Adding a subtle shadow for depth.
          boxShadow: [
            BoxShadow(
              color: isCheckedIn ? Colors.green.withOpacity(0.3) : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        // The centered icon inside the orb.
        child: const Icon(
          Icons.check,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}
