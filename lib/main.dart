
import 'package:flutter/material.dart';
import 'package:momentum/pages/home_page.dart';
import 'package:momentum/services/database_service.dart';
import 'package:momentum/widgets/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that the Flutter binding is initialized before doing any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Create an instance of the DatabaseService.
  final DatabaseService db = DatabaseService();
  
  // Load the persisted data from storage before the app starts.
  await db.loadDb();

  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  final DatabaseService db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to make the DatabaseService available to all
    // descendant widgets. Any widget that is a descendant of MyApp can access
    // the DatabaseService instance and listen for changes.
    return ChangeNotifierProvider.value(
      value: db,
      child: MaterialApp(
        title: 'Momentum',
        theme: AppTheme.darkTheme,
        // The main screen of the application.
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
