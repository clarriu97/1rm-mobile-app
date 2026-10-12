// The store screenshots and the Play feature graphic: the app's real screens
// on the app's iron background, each under a headline. After a visual change,
// regenerate them on macOS and copy them, without alpha as the stores want,
// into fastlane/:
//   flutter test --update-goldens --tags golden test/goldens/store_test.dart
//   tool/store_images.sh
@Tags(['golden'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/l10n/app_localizations.dart';
import 'package:one_rm_mobile/l10n/localized_names.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/link_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/manage_exercises_screen.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';
import 'package:one_rm_mobile/ui/widgets/pr_celebration.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

import '../helpers/test_app.dart';

/// The phone the screens are laid out on: an iPhone 16.
const _phone = Size(393, 852);
const _phoneInsets = EdgeInsets.only(top: 59, bottom: 34);

/// How much of the phone's foot runs off the bottom edge: its home
/// indicator and rounded corners.
const _bleed = 40.0;

/// Where each store wants its screenshots, and their size in pixels.
const _stores = {'app_store': Size(1320, 2868), 'play': Size(1080, 1920)};

const _locales = {'en-US': Locale('en'), 'es-ES': Locale('es')};

final _now = DateTime(2026, 9, 23, 10);
DateTime _clock() => _now;

ExerciseTemplate _lift(String id) =>
    defaultExercises.firstWhere((e) => e.id == id);

final _squat = _lift('back_squat');

ExerciseRecord _record(double weight, int reps, DateTime date) =>
    ExerciseRecord(
      weight: weight,
      reps: reps,
      oneRM: calculateOneRM(weight, reps),
      date: date,
    );

/// A lifter's last nine months: a steady squat, and a few other lifts.
RecordsRepository _records({bool withNewPr = false}) =>
    RecordsRepository(StorageService.inMemoryForTesting(), {
      _squat.id: [
        _record(120, 5, DateTime(2026, 1, 8)),
        _record(125, 5, DateTime(2026, 2, 5)),
        _record(130, 5, DateTime(2026, 3, 5)),
        _record(137.5, 5, DateTime(2026, 4, 9)),
        _record(140, 5, DateTime(2026, 5, 7)),
        _record(147.5, 5, DateTime(2026, 6, 11)),
        _record(140, 5, DateTime(2026, 6, 30)),
        _record(155, 5, DateTime(2026, 7, 16)),
        _record(160, 5, DateTime(2026, 8, 13)),
        _record(165, 5, DateTime(2026, 9, 10)),
        if (withNewPr) _record(175, 4, DateTime(2026, 9, 23, 9)),
      ],
      'bench_press': [
        _record(85, 5, DateTime(2026, 5, 4)),
        _record(90, 5, DateTime(2026, 7, 6)),
        _record(95, 4, DateTime(2026, 9, 18)),
      ],
      'deadlift': [
        _record(180, 5, DateTime(2026, 6, 2)),
        _record(195, 3, DateTime(2026, 9, 2)),
      ],
      'overhead_press': [
        _record(55, 5, DateTime(2026, 6, 20)),
        _record(60, 4, DateTime(2026, 9, 15)),
      ],
      'power_clean': [_record(100, 2, DateTime(2026, 9, 12))],
    });

Widget _detail({bool withNewPr = false}) => ExerciseDetailScreen(
  template: _squat,
  records: _records(withNewPr: withNewPr),
  unit: WeightUnit.kg,
  clock: _clock,
);

/// One screenshot: its file name, headline and line in each language, the
/// screen, and what to do on it before the capture.
class _Story {
  const _Story(this.name, this.text, this.screen, [this.prepare]);

  final String name;
  final Map<String, (String, String)> text;
  final Widget Function(Locale) screen;
  final Future<void> Function(WidgetTester, AppLocalizations)? prepare;
}

final _stories = [
  _Story(
    '01_estimate',
    {
      'en-US': (
        'Your max from any set',
        'Weight × reps, and your 1RM as you type',
      ),
      'es-ES': ('Tu máximo con una serie', 'Peso × reps, y tu 1RM al momento'),
    },
    (locale) => AddEntryScreen(
      exerciseName: lookupAppLocalizations(locale).exerciseName(_squat),
      assetPath: _squat.assetPath,
      unit: WeightUnit.kg,
      clock: _clock,
    ),
    (tester, l10n) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '140');
      await tester.enterText(fields.at(1), '5');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  ),
  _Story(
    '02_working_weights',
    {
      'en-US': (
        'Working weights, ready',
        'From 100% to 50%, rounded to real plates',
      ),
      'es-ES': (
        'Pesos de trabajo listos',
        'Del 100 % al 50 %, en discos reales',
      ),
    },
    (_) => _detail(),
    (tester, l10n) async {
      await Scrollable.ensureVisible(
        tester.element(find.text(l10n.workingWeights)),
      );
      await tester.pumpAndSettle();
    },
  ),
  _Story('03_progress', {
    'en-US': (
      'Watch your strength climb',
      'Your 1RM over time, every PR marked',
    ),
    'es-ES': (
      'Mira cómo sube tu fuerza',
      'Tu 1RM en el tiempo, con cada PR marcado',
    ),
  }, (_) => _detail()),
  _Story(
    '04_new_pr',
    {
      'en-US': (
        'Every PR, celebrated',
        'Beat your best and see what you gained',
      ),
      'es-ES': (
        'Cada PR, celebrado',
        'Supera tu marca y mira cuánto has ganado',
      ),
    },
    (_) => _detail(withNewPr: true),
    (tester, l10n) async {
      final context = tester.element(find.byType(ExerciseDetailScreen));
      final records = _records(withNewPr: true);
      final all = records.recordsFor(_squat.id);
      unawaited(
        showPrCelebration(
          context,
          exerciseName: l10n.exerciseName(_squat),
          oneRM: all.last.oneRM,
          previousBest: all
              .take(all.length - 1)
              .map((r) => r.oneRM)
              .reduce((a, b) => a > b ? a : b),
          unit: WeightUnit.kg,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    },
  ),
  _Story('05_library', {
    'en-US': ('34 lifts, plus your own', 'From the squat to the snatch'),
    'es-ES': ('34 ejercicios, y los tuyos', 'De la sentadilla al snatch'),
  }, (_) => ManageExercisesScreen(library: testLibrary(), records: _records())),
  _Story(
    '06_private',
    {
      'en-US': (
        'No account. No ads.',
        'Everything you log stays on your phone',
      ),
      'es-ES': (
        'Sin cuenta. Sin anuncios.',
        'Todo lo que apuntas se queda en tu móvil',
      ),
    },
    (_) => HomeScreen(
      records: _records(),
      library: testLibrary(),
      unitService: UnitService.forTesting(),
      language: testLanguage(),
      links: LinkService.forTesting(),
      clock: _clock,
    ),
  ),
];

/// [screen] laid out on the phone, in [locale], with rounded corners.
class _Phone extends StatelessWidget {
  const _Phone({
    required this.screen,
    required this.locale,
    required this.width,
  });

  final Widget screen;
  final Locale locale;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scale = width / _phone.width;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(52 * scale),
        border: Border.all(color: AppColors.outline, width: 3 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 60 * scale,
            spreadRadius: 4 * scale,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50 * scale),
        child: SizedBox(
          width: width,
          height: _phone.height * scale,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: _phone,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: _phone,
                  devicePixelRatio: 3,
                  padding: _phoneInsets,
                  viewPadding: _phoneInsets,
                ),
                child: buildTestApp(
                  screen,
                  platform: TargetPlatform.iOS,
                  locale: locale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The iron background: charcoal with a faint knurl.
class _Iron extends StatelessWidget {
  const _Iron({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.background,
    child: CustomPaint(painter: const KnurlPainter(spacing: 10), child: child),
  );
}

/// A headline and its line over the screen, whose foot runs off the bottom.
class _Shot extends StatelessWidget {
  const _Shot({
    required this.headline,
    required this.line,
    required this.screen,
    required this.locale,
  });

  final String headline;
  final String line;
  final Widget screen;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _Iron(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Column(
            children: [
              HazardStripe(height: width * 0.025),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width * 0.07,
                  width * 0.08,
                  width * 0.07,
                  width * 0.07,
                ),
                child: Column(
                  spacing: width * 0.025,
                  children: [
                    Text(
                      headline.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: text.displayMedium?.copyWith(
                        fontSize: width * 0.085,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      line,
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(
                        fontSize: width * 0.045,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, space) {
                    final top = width * 0.02;
                    final phoneWidth =
                        ((space.maxHeight - top) *
                                _phone.width /
                                (_phone.height - _bleed))
                            .clamp(0.0, width * 0.84);
                    return Stack(
                      children: [
                        Positioned(
                          top: top,
                          left: (width - phoneWidth) / 2,
                          child: _Phone(
                            screen: screen,
                            locale: locale,
                            width: phoneWidth,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The Play feature graphic: the icon, the name and its promise, beside the
/// detail screen of a lift.
class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.locale});

  final ImageProvider icon;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = lookupAppLocalizations(locale);
    return _Iron(
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: HazardStripe(height: 12),
          ),
          Positioned(
            left: 64,
            top: 0,
            bottom: 0,
            width: 440,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  spacing: 28,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image(image: icon, width: 160, height: 160),
                    ),
                    Text(
                      '1RM',
                      style: text.displayLarge?.copyWith(fontSize: 150),
                    ),
                  ],
                ),
                Text(
                  l10n.aboutTagline,
                  style: text.titleMedium?.copyWith(
                    fontSize: 34,
                    height: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 64,
            top: 56,
            child: _Phone(screen: _detail(), locale: locale, width: 280),
          ),
        ],
      ),
    );
  }
}

/// SVGs decode asynchronously from the asset bundle; load them for real and
/// rebuild so they appear in the capture.
Future<void> _loadSvgs(WidgetTester tester) async {
  final loaders = {
    for (final picture in tester.widgetList<SvgPicture>(
      find.byType(SvgPicture),
    ))
      picture.bytesLoader,
  };
  await tester.runAsync(() async {
    for (final loader in loaders) {
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  });
  await tester.pump();
}

void _setView(WidgetTester tester, Size pixels, double pixelRatio) {
  tester.view
    ..physicalSize = pixels
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
}

const _canvas = Key('store-image');

/// The composition, outside any app: the screen's own MaterialApp is then
/// the root navigator, where dialogs such as the PR celebration open.
Widget _onCanvas(Widget child) => Directionality(
  key: _canvas,
  textDirection: TextDirection.ltr,
  child: Theme(data: AppTheme.dark, child: child),
);

Future<void> _capture(String path) =>
    expectLater(find.byKey(_canvas), matchesGoldenFile('goldens/store/$path'));

void main() {
  _stores.forEach((store, pixels) {
    _locales.forEach((localeName, locale) {
      for (final story in _stories) {
        testWidgets('${story.name} for $store in $localeName', (tester) async {
          _setView(tester, pixels, pixels.width / 440);
          final (headline, line) = story.text[localeName]!;
          await tester.pumpWidget(
            _onCanvas(
              _Shot(
                headline: headline,
                line: line,
                screen: story.screen(locale),
                locale: locale,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await story.prepare?.call(tester, lookupAppLocalizations(locale));
          await _loadSvgs(tester);
          await _capture('$store/$localeName/${story.name}.png');
          await tester.pumpAndSettle(kPrCelebrationDuration);
        });
      }
    });
  });

  _locales.forEach((localeName, locale) {
    testWidgets('the Play feature graphic in $localeName', (tester) async {
      _setView(tester, const Size(1024, 500), 1);
      final icon = MemoryImage(
        File('assets/branding/app_icon.png').readAsBytesSync(),
      );
      await tester.pumpWidget(_onCanvas(_Feature(icon: icon, locale: locale)));
      await tester.runAsync(
        () => precacheImage(icon, tester.element(find.byType(_Feature))),
      );
      await tester.pumpAndSettle();
      await _loadSvgs(tester);
      await _capture('play/$localeName/feature_graphic.png');
    });
  });
}
