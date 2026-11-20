import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinla/domain/entities/note.dart';
import 'package:tinla/domain/entities/tuning.dart';
import 'package:tinla/domain/services/string_matcher.dart';
import 'package:tinla/domain/tunings.dart';

Tuning _byId(String id) => allTunings.firstWhere((t) => t.id == id);

double _shifted(double target, double cents) => target * pow(2, cents / 1200);

void main() {
  final standard = standardTuning;
  final dropD = _byId('drop-d');
  final bozuk = _byId('baglama-bozuk');
  final invalid = [0.0, -5.0, double.nan, double.infinity];

  test('threshold constant is 5 cents', () {
    expect(inTuneThresholdCents, 5.0);
  });

  group('matchAuto guitar', () {
    test('110 Hz is string 1, 0 cents, in tune', () {
      final result = matchAuto(standard, 110.0);
      expect(result.stringIndex, 1);
      expect(result.cents, closeTo(0, 1e-9));
      expect(result.isInTune, isTrue);
    });
    test('112 Hz is string 1, about +31.2 cents, not in tune', () {
      final result = matchAuto(standard, 112);
      expect(result.stringIndex, 1);
      expect(result.cents, closeTo(31.2, 0.5));
      expect(result.isInTune, isFalse);
    });
    test('4.9 cents sharp is in tune, 5.1 is not', () {
      final target = standard.strings[0].note.frequency;
      final inside = matchAuto(standard, _shifted(target, 4.9));
      final outside = matchAuto(standard, _shifted(target, 5.1));
      expect(inside.stringIndex, 0);
      expect(inside.isInTune, isTrue);
      expect(outside.stringIndex, 0);
      expect(outside.isInTune, isFalse);
    });
    test('negative side of the threshold is symmetric', () {
      final target = standard.strings[0].note.frequency;
      expect(matchAuto(standard, _shifted(target, -4.9)).isInTune, isTrue);
      expect(matchAuto(standard, _shifted(target, -5.1)).isInTune, isFalse);
    });
    test('exact tie goes to the lower index (two equal strings)', () {
      // Deterministic tie: a custom tuning with two identical strings.
      const tied = Tuning(
        id: 'tied',
        name: 'Tied',
        instrument: Instrument.guitar,
        strings: [TuningString(Note(40), 'E2'), TuningString(Note(40), 'E2')],
      );
      expect(matchAuto(tied, 82.41).stringIndex, 0);
    });
    test('geometric midpoint of strings 0 and 1 resolves to the nearer', () {
      // Midpoint built in the cent domain. The two |cents| can differ by an
      // ulp, so the expected winner comes from the same centsBetween
      // arithmetic the implementation uses; the exact tie is covered above.
      final low = standard.strings[0].note.frequency;
      final high = standard.strings[1].note.frequency;
      final midpoint = sqrt(low * high);
      final toLow = centsBetween(midpoint, low).abs();
      final toHigh = centsBetween(midpoint, high).abs();
      final result = matchAuto(standard, midpoint);
      expect(result.stringIndex, toHigh < toLow ? 1 : 0);
      expect(result.cents.abs(), closeTo(250, 1e-6));
    });
    test('220 Hz is not in tune for guitar string 1 (octaves exact)', () {
      final result = matchManual(standard, 1, 220);
      expect(result.cents, closeTo(1200, 1e-6));
      expect(result.isInTune, isFalse);
    });
    test('Drop D 73.42 Hz is string 0 and in tune', () {
      final result = matchAuto(dropD, 73.42);
      expect(result.stringIndex, 0);
      expect(result.isInTune, isTrue);
    });
  });

  group('matchAuto baglama', () {
    test('220, 110 and 440 Hz all hit string 0 at about 0 cents', () {
      for (final frequency in [220.0, 110.0, 440.0]) {
        final result = matchAuto(bozuk, frequency);
        expect(result.stringIndex, 0, reason: '$frequency');
        expect(result.cents, closeTo(0, 1e-6), reason: '$frequency');
      }
    });
    test('146.83 Hz is string 1', () {
      expect(matchAuto(bozuk, 146.83).stringIndex, 1);
    });
    test('392 Hz is string 2', () {
      expect(matchAuto(bozuk, 392).stringIndex, 2);
    });
    test('330 Hz still maps to a nearest course within 600 cents', () {
      final result = matchAuto(bozuk, 330);
      expect(result.stringIndex, inInclusiveRange(0, 2));
      expect(result.cents.abs(), lessThanOrEqualTo(600));
    });
  });

  group('matchManual', () {
    test('string 3 at 190 Hz is about -53.8 cents, no clamping', () {
      // Brief says "about -52"; 1200*log2(190/196) is -53.8.
      final result = matchManual(standard, 3, 190);
      expect(result.stringIndex, 3);
      expect(result.cents, closeTo(-53.8, 0.1));
      expect(result.isInTune, isFalse);
    });
    test('baglama manual folds octaves', () {
      final result = matchManual(bozuk, 0, 220);
      expect(result.cents, closeTo(0, 1e-6));
      expect(result.isInTune, isTrue);
    });
  });

  group('input validation', () {
    test('matchAuto throws on non-finite or non-positive frequency', () {
      for (final value in invalid) {
        expect(() => matchAuto(standard, value), throwsArgumentError);
      }
    });
    test('matchManual throws on bad frequency', () {
      for (final value in invalid) {
        expect(() => matchManual(standard, 0, value), throwsArgumentError);
      }
    });
    test('matchManual throws on out-of-range index', () {
      expect(() => matchManual(standard, -1, 110), throwsArgumentError);
      expect(() => matchManual(standard, 6, 110), throwsArgumentError);
      expect(() => matchManual(bozuk, 3, 110), throwsArgumentError);
    });
  });
}
