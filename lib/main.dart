import 'package:flutter/material.dart';
import 'ui/app_theme.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OneRMApp());
}

class OneRMApp extends StatelessWidget {
  const OneRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1RM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
