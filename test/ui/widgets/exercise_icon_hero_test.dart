import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/services/link_service.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/widgets/exercise_icon_hero.dart';

import '../../helpers/test_app.dart';

void main() {
  final squat = defaultExercises.first;

  Widget home({bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: buildTestApp(
      HomeScreen(
        records: RecordsRepository(StorageService.inMemoryForTesting(), {
          squat.id: [
            ExerciseRecord(
              weight: 100,
              reps: 1,
              oneRM: 100,
              date: DateTime(2026, 9, 22),
            ),
          ],
        }),
        library: testLibrary(),
        unitService: UnitService.forTesting(),
        language: testLanguage(),
        links: LinkService.forTesting(),
      ),
      platform: TargetPlatform.iOS,
    ),
  );

  Finder heroOf(String id) => find.byWidgetPredicate(
    (w) => w is Hero && w.tag == ExerciseIconHero.tagFor(id),
  );

  /// The squat icon on screen (not a hidden hero placeholder).
  final squatIcon = find.byWidgetPredicate(
    (w) =>
        w is SvgPicture &&
        w.bytesLoader is SvgAssetLoader &&
        (w.bytesLoader as SvgAssetLoader).assetName == squat.assetPath,
  );

  Future<void> openSquat(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel(RegExp('^Back Squat')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('ExerciseIconHero', () {
    testWidgets('every Home card has its own tag', (tester) async {
      await tester.pumpWidget(home());
      await tester.pumpAndSettle();

      final tags = tester.widgetList<Hero>(find.byType(Hero)).map((h) => h.tag);
      expect(tags.toSet(), hasLength(tags.length));
      expect(heroOf(squat.id), findsOneWidget);
    });

    testWidgets('the icon flies from the card to the Detail title', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(home());
      await tester.pumpAndSettle();
      final onCard = tester.getCenter(squatIcon);

      await openSquat(tester);
      // Mid-flight only the flying copy is drawn; source and destination
      // show placeholders.
      final inFlight = tester.getCenter(squatIcon);
      await tester.pumpAndSettle();
      final inTitle = tester.getCenter(squatIcon);

      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      expect(inFlight.dy, inExclusiveRange(inTitle.dy, onCard.dy));
      expect(inFlight.dx, inExclusiveRange(onCard.dx, inTitle.dx));
      semantics.dispose();
    });

    testWidgets('no flight with reduced motion', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(home(reduceMotion: true));
      await tester.pumpAndSettle();

      expect(
        tester
            .widgetList<HeroMode>(find.byType(HeroMode))
            .every((mode) => !mode.enabled),
        isTrue,
      );
      await openSquat(tester);
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      semantics.dispose();
    });
  });
}
