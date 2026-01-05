import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/screens/home_screen.dart';
import 'core/screens/history_screen.dart';

/// Momentum - Minimalist Habit Tracker
/// PRD Philosophy: "Friction kills habits."
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MomentumApp(),
    ),
  );
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.zinc900,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.zinc800,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.zinc700,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    icon: Icons.home_rounded,
                    label: 'CHECK-IN',
                    isActive: _currentIndex == 0,
                    onTap: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NavButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'HISTORY',
                    isActive: _currentIndex == 1,
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.zinc700 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.zinc100 : AppTheme.zinc600,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isActive ? AppTheme.zinc100 : AppTheme.zinc600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}