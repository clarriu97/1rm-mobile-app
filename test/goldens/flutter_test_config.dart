import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pixel only counts as changed when a colour channel moves by more than
/// this (out of 255). Text antialiasing differs slightly between machines;
/// measured between a local Mac and the CI runner it stays well under this
/// for almost every pixel.
const _channelTolerance = 32;

/// Fraction of changed pixels allowed (0.01 %). Machine noise measured at
/// most 0.003 %; changing one letter of the Home title is about 0.1 %.
const _pixelTolerance = 0.0001;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAppFonts();
  final base = (goldenFileComparator as LocalFileComparator).basedir;
  goldenFileComparator = _TolerantComparator(base.resolve('golden_test.dart'));
  await testMain();
}

/// Tests render text with a placeholder font unless the real ones are
/// registered; load every font the app bundles, Material icons included.
Future<void> _loadAppFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final goldenBytes = Uint8List.fromList(await getGoldenBytes(golden));
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    try {
      if (result.passed) return true;
      final changed = await _changedPixels(imageBytes, goldenBytes);
      if (changed != null && changed <= _pixelTolerance) return true;
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }
}

/// Share of pixels whose colour changed beyond [_channelTolerance], or null
/// when the sizes differ.
Future<double?> _changedPixels(Uint8List a, Uint8List b) async {
  final (imageA, pixelsA) = await _decode(a);
  final (imageB, pixelsB) = await _decode(b);
  try {
    if (imageA.width != imageB.width || imageA.height != imageB.height) {
      return null;
    }
    var changed = 0;
    for (var i = 0; i < pixelsA.length; i += 4) {
      var delta = 0;
      for (var c = 0; c < 4; c++) {
        delta = math.max(delta, (pixelsA[i + c] - pixelsB[i + c]).abs());
      }
      if (delta > _channelTolerance) changed++;
    }
    return changed / (imageA.width * imageA.height);
  } finally {
    imageA.dispose();
    imageB.dispose();
  }
}

Future<(ui.Image, Uint8List)> _decode(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  final image = (await codec.getNextFrame()).image;
  codec.dispose();
  final data = await image.toByteData();
  return (image, data!.buffer.asUint8List());
}
