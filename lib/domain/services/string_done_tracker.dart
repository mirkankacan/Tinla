/// Tracks which strings have been held in tune long enough to count as done.
///
/// Frame-based, no clock: call [update] once per analysis frame (about 46 ms).
/// The consecutive counters belong to the current string only. A frame for a
/// different string index, or a null frame, resets both counters.
class StringDoneTracker {
  StringDoneTracker({
    this.holdFrames = 13,
    this.doneBandCents = 5.0,
    this.releaseCents = 15.0,
    this.releaseFrames = 3,
  }) {
    if (holdFrames < 1) {
      throw ArgumentError.value(holdFrames, 'holdFrames', 'must be > 0');
    }
    if (doneBandCents <= 0) {
      throw ArgumentError.value(doneBandCents, 'doneBandCents', 'must be > 0');
    }
    if (releaseCents <= 0) {
      throw ArgumentError.value(releaseCents, 'releaseCents', 'must be > 0');
    }
    if (releaseFrames < 1) {
      throw ArgumentError.value(releaseFrames, 'releaseFrames', 'must be > 0');
    }
  }

  /// Consecutive in-band frames needed to mark a string done.
  final int holdFrames;

  /// A frame counts as in band when |cents| is at most this.
  final double doneBandCents;

  /// A frame counts toward release when |cents| is above this.
  final double releaseCents;

  /// Consecutive out-of-band frames needed to un-done a done string.
  final int releaseFrames;

  final Set<int> _done = <int>{};
  int? _currentIndex;
  var _inBandFrames = 0;
  var _releaseFramesSeen = 0;

  /// Feeds one frame and returns an unmodifiable copy of the done set.
  ///
  /// A string becomes done after [holdFrames] consecutive frames with
  /// |cents| <= [doneBandCents]. A done string stops being done after
  /// [releaseFrames] consecutive frames with |cents| > [releaseCents] for
  /// that same string. A null index or null cents frame changes no done
  /// string and breaks both consecutive counts.
  Set<int> update({required int? stringIndex, required double? cents}) {
    if (stringIndex == null || cents == null) {
      _resetCounters();
      return Set.unmodifiable(_done);
    }
    if (stringIndex != _currentIndex) {
      _resetCounters();
      _currentIndex = stringIndex;
    }
    final magnitude = cents.abs();

    if (magnitude <= doneBandCents) {
      _inBandFrames++;
      if (_inBandFrames >= holdFrames) _done.add(stringIndex);
    } else {
      _inBandFrames = 0;
    }

    if (magnitude > releaseCents) {
      _releaseFramesSeen++;
      if (_releaseFramesSeen >= releaseFrames) _done.remove(stringIndex);
    } else {
      _releaseFramesSeen = 0;
    }
    return Set.unmodifiable(_done);
  }

  /// Clears the done set and all counters.
  void reset() {
    _done.clear();
    _resetCounters();
  }

  void _resetCounters() {
    _currentIndex = null;
    _inBandFrames = 0;
    _releaseFramesSeen = 0;
  }
}
