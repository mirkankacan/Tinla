import 'package:flutter_test/flutter_test.dart';
import 'package:tinla/domain/entities/tuning.dart';
import 'package:tinla/domain/tunings.dart';

Tuning _byName(Instrument instrument, String name) =>
    tuningsFor(instrument).singleWhere((t) => t.name == name);

void main() {
  test('guitar tunings have 6 strictly ascending strings', () {
    for (final tuning in tuningsFor(Instrument.guitar)) {
      expect(tuning.strings, hasLength(6), reason: tuning.name);
      for (var i = 1; i < tuning.strings.length; i++) {
        expect(
          tuning.strings[i].note.midi,
          greaterThan(tuning.strings[i - 1].note.midi),
          reason: tuning.name,
        );
      }
    }
  });

  test('baglama tunings have exactly 3 strings', () {
    for (final tuning in tuningsFor(Instrument.baglama)) {
      expect(tuning.strings, hasLength(3), reason: tuning.name);
      final midis = tuning.strings.map((s) => s.note.midi).toList();
      expect(midis, orderedEquals([...midis]..sort()), reason: tuning.name);
    }
  });

  test('standard frequencies match the spec', () {
    final frequencies = standardTuning.strings
        .map((s) => s.note.frequency)
        .toList();
    const expected = [82.41, 110.00, 146.83, 196.00, 246.94, 329.63];
    for (var i = 0; i < expected.length; i++) {
      expect(frequencies[i], closeTo(expected[i], 0.01));
    }
  });

  test('Open C lowest string is about 65.41 Hz', () {
    final openC = _byName(Instrument.guitar, 'Open C');
    expect(openC.strings.first.note.frequency, closeTo(65.41, 0.01));
  });

  test('ids are unique and counts match', () {
    final ids = allTunings.map((t) => t.id).toSet();
    expect(ids, hasLength(allTunings.length));
    expect(tuningsFor(Instrument.guitar), hasLength(11));
    expect(tuningsFor(Instrument.baglama), hasLength(10));
  });

  test('catalog lists are unmodifiable', () {
    expect(
      () => tuningsFor(Instrument.guitar).removeLast(),
      throwsUnsupportedError,
    );
  });

  test('Bozuk labels and default', () {
    final bozuk = defaultTuningFor(Instrument.baglama);
    expect(bozuk.name, 'Bozuk');
    expect(bozuk.strings.map((s) => s.label), ['La (A)', 'Re (D)', 'Sol (G)']);
    expect(defaultTuningFor(Instrument.guitar).id, standardTuning.id);
  });

  test('Bozuk string 0 is A2 and transposedBy shifts notes, not labels', () {
    final bozuk = defaultTuningFor(Instrument.baglama);
    expect(bozuk.strings[0].note.frequency, closeTo(110.00, 0.01));
    final shifted = bozuk.transposedBy(5);
    expect(shifted.strings[0].note.frequency, closeTo(146.83, 0.01));
    expect(shifted.strings[0].label, 'La (A)');
    expect(shifted.id, bozuk.id);
    expect(shifted.name, bozuk.name);
  });

  test('transposedBy(0) keeps frequencies', () {
    final bozuk = defaultTuningFor(Instrument.baglama);
    final same = bozuk.transposedBy(0);
    for (var i = 0; i < 3; i++) {
      expect(same.strings[i].note.frequency, bozuk.strings[i].note.frequency);
    }
  });

  test('SazSize offsets and labels', () {
    expect(SazSize.uzunSap.defaultOffsetSemitones, 0);
    expect(SazSize.kisaSap.defaultOffsetSemitones, 5);
    expect(SazSize.uzunSap.label, 'Uzun Sap');
    expect(SazSize.kisaSap.label, 'Kısa Sap');
  });

  test('free tier is exactly the named tunings', () {
    final free = allTunings.where((t) => t.isFree).map((t) => t.name).toSet();
    expect(free, {
      'Standard',
      'Drop D',
      'Half Step Down',
      'Bozuk',
      'Bağlama Düzeni',
    });
    expect(
      allTunings.where((t) => t.isFree && t.instrument == Instrument.guitar),
      hasLength(3),
    );
    expect(
      allTunings.where((t) => t.isFree && t.instrument == Instrument.baglama),
      hasLength(2),
    );
  });
}
