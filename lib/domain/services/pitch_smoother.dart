import 'dart:collection';

import '../entities/pitch_reading.dart';

/// Readings with lower detector clarity are rejected.
const minClarity = 0.85;

/// Readings with a lower window RMS are rejected as silence or room noise.
const minLevel = 0.01;

/// Lowest accepted frequency in Hz.
const minFrequency = 55.0;

/// Highest accepted frequency in Hz.
const maxFrequency = 1000.0;

/// Gates raw readings and smooths them with a running median.
///
/// Frame-based and deterministic: no clocks. Call [add] once per analysis
/// frame.
class PitchSmoother {
  PitchSmoother({this.windowSize = 5, this.dropoutFrames = 6}) {
    if (windowSize < 1) {
      throw ArgumentError.value(windowSize, 'windowSize', 'must be > 0');
    }
    if (dropoutFrames < 1) {
      throw ArgumentError.value(dropoutFrames, 'dropoutFrames', 'must be > 0');
    }
  }

  /// How many accepted frequencies the median covers.
  final int windowSize;

  /// Consecutive rejected or null frames after which the output is null.
  final int dropoutFrames;

  final Queue<double> _accepted = Queue<double>();
  var _rejectedInARow = 0;

  /// Feeds one frame. Returns the median of the last [windowSize] accepted
  /// frequencies, or null when there is no usable pitch.
  ///
  /// A single rejected frame keeps returning the last median. After
  /// [dropoutFrames] consecutive rejected frames the history is cleared and
  /// null is returned until a frame is accepted again.
  double? add(PitchReading? reading) {
    if (_isAccepted(reading)) {
      _rejectedInARow = 0;
      _accepted.addLast(reading!.frequency);
      if (_accepted.length > windowSize) {
        _accepted.removeFirst();
      }
      return _median();
    }
    if (_rejectedInARow < dropoutFrames) {
      _rejectedInARow++;
    }
    if (_rejectedInARow >= dropoutFrames) {
      _accepted.clear();
      return null;
    }
    return _accepted.isEmpty ? null : _median();
  }

  /// Clears history and the rejected-frame counter.
  void reset() {
    _accepted.clear();
    _rejectedInARow = 0;
  }

  static bool _isAccepted(PitchReading? reading) {
    if (reading == null) return false;
    final frequency = reading.frequency;
    return frequency.isFinite &&
        frequency >= minFrequency &&
        frequency <= maxFrequency &&
        reading.clarity.isFinite &&
        reading.clarity >= minClarity &&
        reading.level.isFinite &&
        reading.level >= minLevel;
  }

  double _median() {
    final sorted = _accepted.toList()..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
