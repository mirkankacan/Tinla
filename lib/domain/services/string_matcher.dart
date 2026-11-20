import '../entities/note.dart';
import '../entities/tuning.dart';

/// A string counts as in tune when its deviation is within this many cents.
const inTuneThresholdCents = 5.0;

/// The outcome of matching a frequency against one string of a tuning.
class MatchResult {
  const MatchResult({required this.stringIndex, required this.cents});

  /// Index into the tuning's strings (low to high).
  final int stringIndex;

  /// Signed deviation from the string's target pitch, unclamped.
  /// Positive means sharp (too high), negative means flat (too low).
  final double cents;

  /// True when |[cents]| is within [inTuneThresholdCents], inclusive.
  bool get isInTune => cents.abs() <= inTuneThresholdCents;
}

/// Picks the string with the smallest |cents|; ties go to the lower index.
/// Guitar matches exact pitch, bağlama matches octave-folded.
///
/// Throws [ArgumentError] when [frequency] is not finite and > 0, or when
/// [tuning] has no strings.
MatchResult matchAuto(Tuning tuning, double frequency) {
  _checkFrequency(frequency);
  if (tuning.strings.isEmpty) {
    throw ArgumentError.value(
      tuning,
      'tuning',
      'must have at least one string',
    );
  }
  var bestIndex = 0;
  var bestCents = _centsFor(tuning, 0, frequency);
  for (var i = 1; i < tuning.strings.length; i++) {
    final cents = _centsFor(tuning, i, frequency);
    if (cents.abs() < bestCents.abs()) {
      bestIndex = i;
      bestCents = cents;
    }
  }
  return MatchResult(stringIndex: bestIndex, cents: bestCents);
}

/// Measures [frequency] against the chosen string only.
///
/// Throws [ArgumentError] when [frequency] is not finite and > 0, or when
/// [stringIndex] is outside the tuning's strings.
MatchResult matchManual(Tuning tuning, int stringIndex, double frequency) {
  _checkFrequency(frequency);
  if (stringIndex < 0 || stringIndex >= tuning.strings.length) {
    throw ArgumentError.value(
      stringIndex,
      'stringIndex',
      'must be in 0..${tuning.strings.length - 1}',
    );
  }
  return MatchResult(
    stringIndex: stringIndex,
    cents: _centsFor(tuning, stringIndex, frequency),
  );
}

double _centsFor(Tuning tuning, int index, double frequency) {
  final target = tuning.strings[index].note.frequency;
  return tuning.instrument == Instrument.baglama
      ? centsFolded(frequency, target)
      : centsBetween(frequency, target);
}

void _checkFrequency(double frequency) {
  if (!frequency.isFinite || frequency <= 0) {
    throw ArgumentError.value(frequency, 'frequency', 'must be finite and > 0');
  }
}
