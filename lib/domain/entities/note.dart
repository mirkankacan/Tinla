import 'dart:math';

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

/// A pitch in 12-tone equal temperament, A4 = 440 Hz, identified by MIDI
/// number (A4 = 69). Names use sharps; display labels live in `TuningString`.
class Note {
  const Note(this.midi);

  final int midi;

  String get name => _noteNames[midi % 12];

  /// Scientific pitch octave (MIDI 60 is C4).
  int get octave => (midi / 12).floor() - 1;

  double get frequency => 440 * pow(2, (midi - 69) / 12).toDouble();

  String get label => '$name$octave';
}

/// Signed distance from [target] to [frequency] in cents.
///
/// [frequency] and [target] must be finite and > 0, else [ArgumentError].
double centsBetween(double frequency, double target) {
  _checkPositiveFinite(frequency, 'frequency');
  _checkPositiveFinite(target, 'target');
  return 1200 * log(frequency / target) / ln2;
}

/// Like [centsBetween] but octave-folded into [-600, 600).
///
/// [frequency] and [target] must be finite and > 0, else [ArgumentError].
double centsFolded(double frequency, double target) {
  final cents = centsBetween(frequency, target);
  return cents - 1200 * ((cents + 600) / 1200).floor();
}

void _checkPositiveFinite(double value, String name) {
  if (!value.isFinite || value <= 0) {
    throw ArgumentError.value(value, name, 'must be finite and > 0');
  }
}
