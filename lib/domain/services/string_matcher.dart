import '../entities/note.dart';
import '../entities/tuning.dart';

/// A string counts as in tune when its deviation is within this many cents.
const inTuneThresholdCents = 5.0;

class MatchResult {
  const MatchResult({required this.stringIndex, required this.cents});

  final int stringIndex;

  /// Signed deviation from the string's target pitch, unclamped.
  final double cents;

  bool get isInTune => cents.abs() <= inTuneThresholdCents;
}

/// Picks the string with the smallest |cents|; ties go to the lower index.
/// Guitar matches exact pitch, bağlama matches octave-folded.
MatchResult matchAuto(Tuning tuning, double frequency) {
  _checkFrequency(frequency);
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
