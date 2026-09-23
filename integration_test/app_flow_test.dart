import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/services/onboarding_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dataDir;

  setUp(() async {
    dataDir = await Directory.systemTemp.createTemp('app_flow_');
  });

  tearDown(() => dataDir.delete(recursive: true));

  Future<StorageService> storage() =>
      StorageService.getInstanceForTesting(directory: dataDir);

  testWidgets('onboarding → log a lift → see 1RM → delete it', (tester) async {
    final records = await RecordsRepository.load(await storage());

    await tester.pumpWidget(
      OneRMApp(
        records: records,
        library: ExerciseLibrary(ExerciseLibraryService.forTesting()),
        onboarding: OnboardingService.forTesting(),
        unitService: UnitService.forTesting(),
      ),
    );
    await tester.pumpAndSettle();

    // Onboarding: four pages (the last one picks the lifts), then home.
    expect(find.text('What is 1RM?'), findsOneWidget);
    for (var page = 0; page < 4; page++) {
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
    }
    expect(find.text('1RM'), findsOneWidget);

    // Log 100 kg × 5 on Back Squat.
    await tester.tap(find.text('Back Squat'));
    await tester.pumpAndSettle();
    expect(find.text('No records yet'), findsOneWidget);

    await tester.tap(find.text('Add Entry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '100');
    await tester.enterText(find.byType(TextFormField).at(1), '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('116.7 kg'), findsWidgets);
    expect(find.text('Working weights'), findsOneWidget);

    // Persisted to disk before leaving the screen.
    var saved = await tester.runAsync(() async => (await storage()).load());
    expect(saved!['back_squat'], hasLength(1));

    // Delete it from history (no dialog, undoable).
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('No records yet'), findsOneWidget);

    saved = await tester.runAsync(() async => (await storage()).load());
    expect(saved, isEmpty);

    // Back to home: no best 1RM left.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('116.7 kg'), findsNothing);
  });
}
