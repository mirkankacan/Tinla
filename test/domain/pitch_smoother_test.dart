import 'package:flutter_test/flutter_test.dart';
import 'package:tinla/domain/entities/pitch_reading.dart';
import 'package:tinla/domain/services/pitch_smoother.dart';

PitchReading _reading(
  double frequency, {
  double clarity = 0.95,
  double level = 0.1,
}) => PitchReading(frequency: frequency, clarity: clarity, level: level);

void main() {
  test('gate constants', () {
    expect(minClarity, 0.85);
    expect(minLevel, 0.01);
    expect(minFrequency, 55.0);
    expect(maxFrequency, 1000.0);
  });

  group('gating', () {
    test('rejected readings return null before any accepted reading', () {
      final smoother = PitchSmoother();
      expect(smoother.add(null), isNull);
      expect(smoother.add(_reading(110, level: 0.009)), isNull);
      expect(smoother.add(_reading(110, clarity: 0.84)), isNull);
      expect(smoother.add(_reading(54.9)), isNull);
      expect(smoother.add(_reading(1000.1)), isNull);
    });
    test('boundary values are accepted', () {
      expect(PitchSmoother().add(_reading(55.0)), 55.0);
      expect(PitchSmoother().add(_reading(1000.0)), 1000.0);
      expect(PitchSmoother().add(_reading(110, clarity: 0.85)), 110.0);
      expect(PitchSmoother().add(_reading(110, level: 0.01)), 110.0);
    });
    test('NaN and infinite values are rejected without throwing', () {
      final smoother = PitchSmoother();
      expect(smoother.add(_reading(double.nan)), isNull);
      expect(smoother.add(_reading(double.infinity)), isNull);
      expect(smoother.add(_reading(110, clarity: double.nan)), isNull);
      expect(smoother.add(_reading(110, level: double.nan)), isNull);
      expect(smoother.add(_reading(110, clarity: double.infinity)), isNull);
      expect(smoother.add(_reading(110, level: double.infinity)), isNull);
    });
  });

  group('smoothing', () {
    test('median ignores a single outlier', () {
      final smoother = PitchSmoother();
      double? result;
      for (final frequency in [110.0, 110.2, 109.8, 110.1, 180.0]) {
        result = smoother.add(_reading(frequency));
      }
      expect(result, closeTo(110.1, 1e-9));
    });
    test('even count uses the mean of the two middle values', () {
      final smoother = PitchSmoother();
      smoother.add(_reading(100));
      expect(smoother.add(_reading(110)), closeTo(105, 1e-9));
    });
    test('window is bounded to the last windowSize accepted readings', () {
      final smoother = PitchSmoother(windowSize: 3);
      for (final frequency in [100.0, 100.0, 100.0]) {
        smoother.add(_reading(frequency));
      }
      smoother.add(_reading(200));
      expect(smoother.add(_reading(200)), 200.0);
    });
  });

  group('dropout', () {
    test('null after dropoutFrames consecutive rejected frames', () {
      final smoother = PitchSmoother();
      smoother.add(_reading(110));
      for (var i = 0; i < 5; i++) {
        expect(smoother.add(null), 110.0, reason: 'frame ${i + 1}');
      }
      expect(smoother.add(null), isNull);
      expect(smoother.add(null), isNull);
    });
    test('a single rejected frame keeps the last median', () {
      final smoother = PitchSmoother();
      smoother.add(_reading(110));
      expect(smoother.add(_reading(110, level: 0)), 110.0);
      expect(smoother.add(_reading(110)), 110.0);
    });
    test('rejected counter resets on an accepted frame', () {
      final smoother = PitchSmoother();
      smoother.add(_reading(110));
      for (var i = 0; i < 5; i++) {
        smoother.add(null);
      }
      smoother.add(_reading(110));
      for (var i = 0; i < 5; i++) {
        expect(smoother.add(null), 110.0);
      }
      expect(smoother.add(null), isNull);
    });
    test('old history never reappears after dropout', () {
      final smoother = PitchSmoother();
      for (var i = 0; i < 5; i++) {
        smoother.add(_reading(110));
      }
      for (var i = 0; i < 6; i++) {
        smoother.add(null);
      }
      expect(smoother.add(_reading(220)), 220.0);
    });
  });

  test('reset clears history', () {
    final smoother = PitchSmoother();
    for (var i = 0; i < 5; i++) {
      smoother.add(_reading(110));
    }
    smoother.reset();
    expect(smoother.add(_reading(220)), 220.0);
  });

  test('reset after dropout clears the rejected counter', () {
    final smoother = PitchSmoother();
    smoother.add(_reading(110));
    for (var i = 0; i < 6; i++) {
      smoother.add(null);
    }
    smoother.reset();
    smoother.add(_reading(110));
    expect(smoother.add(null), 110.0);
  });

  test('constructor validates arguments', () {
    expect(() => PitchSmoother(windowSize: 0), throwsArgumentError);
    expect(() => PitchSmoother(dropoutFrames: 0), throwsArgumentError);
  });
}
