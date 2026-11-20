import 'note.dart';

enum Instrument { guitar, baglama }

class TuningString {
  const TuningString(this.note, this.label);

  final Note note;

  /// What the UI shows, e.g. `E2` (guitar) or `La (A)` (bağlama).
  final String label;
}

class Tuning {
  const Tuning({
    required this.id,
    required this.name,
    required this.instrument,
    required this.strings,
    this.isFree = false,
  });

  final String id;
  final String name;
  final Instrument instrument;

  /// Low to high; bağlama is alt, orta, üst.
  final List<TuningString> strings;
  final bool isFree;

  /// Same id, name and labels with every note shifted by [semitones].
  Tuning transposedBy(int semitones) => Tuning(
    id: id,
    name: name,
    instrument: instrument,
    isFree: isFree,
    strings: List.unmodifiable([
      for (final string in strings)
        TuningString(Note(string.note.midi + semitones), string.label),
    ]),
  );
}

enum SazSize {
  uzunSap(0, 'Uzun Sap'),
  // UNVERIFIED: sources disagree on the absolute pitch; the user can adjust it.
  kisaSap(5, 'Kısa Sap');

  const SazSize(this.defaultOffsetSemitones, this.label);

  final int defaultOffsetSemitones;
  final String label;
}
