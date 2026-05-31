import 'package:flutter/material.dart';
import 'models/exercise.dart';
import 'services/storage_service.dart';
import 'ui/app_theme.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.getInstance();
  final initialRecords = await storage.load();

  runApp(OneRMApp(initialRecords: initialRecords, storage: storage));
}

class OneRMApp extends StatelessWidget {
  const OneRMApp({
    super.key,
    required this.initialRecords,
    required this.storage,
  });

  final Map<String, List<ExerciseRecord>> initialRecords;
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1RM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(initialRecords: initialRecords, storage: storage),
    );
  }
}
