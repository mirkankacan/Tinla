import 'package:flutter_test/flutter_test.dart';
import 'package:tinla/domain/entities/note.dart';

void main() {
  group('Note.frequency', () {
    test('E2 is about 82.41 Hz', () {
      expect(const Note(40).frequency, closeTo(82.41, 0.01));
    });
    test('A2 is about 110 Hz', () {
      expect(const Note(45).frequency, closeTo(110.0, 0.01));
    });
    test('A4 is exactly 440 Hz', () {
      expect(const Note(69).frequency, 440.0);
    });
  });

  group('Note naming', () {
    test('derives name, octave and label from midi', () {
      expect(const Note(40).name, 'E');
      expect(const Note(40).octave, 2);
      expect(const Note(40).label, 'E2');
      expect(const Note(54).label, 'F#3');
    });
    test('octave uses floor division for negative midi', () {
      expect(const Note(0).octave, -1);
      expect(const Note(-1).octave, -2);
      expect(const Note(-1).name, 'B');
    });
  });

  group('input validation', () {
    final invalid = [0.0, -1.0, double.nan, double.infinity];
    test('centsBetween throws ArgumentError on bad frequency or target', () {
      for (final value in invalid) {
        expect(() => centsBetween(value, 440), throwsArgumentError);
        expect(() => centsBetween(440, value), throwsArgumentError);
      }
    });
    test('centsFolded throws ArgumentError on bad frequency or target', () {
      for (final value in invalid) {
        expect(() => centsFolded(value, 440), throwsArgumentError);
        expect(() => centsFolded(440, value), throwsArgumentError);
      }
    });
  });

  group('centsBetween', () {
    test('equal frequencies are 0', () {
      expect(centsBetween(440, 440), 0);
    });
    test('an octave up is 1200', () {
      expect(centsBetween(880, 440), closeTo(1200, 0.001));
    });
    test('A2 over E2 is 5 semitones, about 500', () {
      expect(centsBetween(110.0, 82.41), closeTo(500, 1));
    });
  });

  group('centsFolded', () {
    test('octave below and above fold to 0', () {
      expect(centsFolded(220, 110), closeTo(0, 1e-9));
      expect(centsFolded(110, 440), closeTo(0, 1e-9));
    });
    test('slightly sharp stays positive', () {
      expect(centsFolded(115, 110), closeTo(77, 1));
    });
    test('a fourth above folds to a negative fifth below', () {
      expect(centsFolded(165, 110), closeTo(-498, 1));
    });
  });
}
