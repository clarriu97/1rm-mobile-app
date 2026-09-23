import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CustomExerciseData.tryFromJson', () {
    test('parses a valid entry', () {
      final data = CustomExerciseData.tryFromJson({
        'id': 'custom_1',
        'name': 'Zercher Squat',
      });
      expect(data!.id, 'custom_1');
      expect(data.name, 'Zercher Squat');
    });

    test('rejects missing, empty or wrongly typed fields', () {
      expect(CustomExerciseData.tryFromJson(null), isNull);
      expect(CustomExerciseData.tryFromJson('x'), isNull);
      expect(CustomExerciseData.tryFromJson({'id': 'a'}), isNull);
      expect(CustomExerciseData.tryFromJson({'id': '', 'name': 'x'}), isNull);
      expect(CustomExerciseData.tryFromJson({'id': 'a', 'name': ''}), isNull);
      expect(CustomExerciseData.tryFromJson({'id': 1, 'name': 'x'}), isNull);
    });
  });

  group('ExerciseLibraryService (SharedPreferences)', () {
    Future<ExerciseLibraryService> service([
      Map<String, Object> initial = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(initial);
      return ExerciseLibraryService.getInstance();
    }

    test('starts empty', () async {
      final s = await service();
      expect(await s.loadCustom(), isEmpty);
      expect(await s.loadHidden(), isEmpty);
      expect(await s.loadShown(), isEmpty);
    });

    test('round-trips custom exercises and hidden ids', () async {
      final s = await service();
      await s.saveCustom(const [
        CustomExerciseData(id: 'custom_1', name: 'Zercher Squat'),
        CustomExerciseData(id: 'custom_2', name: 'Pin Press'),
      ]);
      await s.saveHidden({'snatch', 'custom_2'});
      await s.saveShown({'thruster'});

      final reloaded = await ExerciseLibraryService.getInstance();
      expect(await reloaded.loadShown(), {'thruster'});
      expect((await reloaded.loadCustom()).map((e) => e.name), [
        'Zercher Squat',
        'Pin Press',
      ]);
      expect(await reloaded.loadHidden(), {'snatch', 'custom_2'});
    });

    test('corrupted or partially invalid JSON never crashes', () async {
      expect(
        await (await service({'custom_exercises': '{not json'})).loadCustom(),
        isEmpty,
      );
      expect(
        await (await service({'custom_exercises': '{"a": 1}'})).loadCustom(),
        isEmpty,
      );
      final partial = await service({
        'custom_exercises': '[{"id": "c1", "name": "Ok"}, {"id": 3}, "x"]',
      });
      expect((await partial.loadCustom()).single.name, 'Ok');
    });
  });
}
