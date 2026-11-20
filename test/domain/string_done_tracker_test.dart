import 'package:flutter_test/flutter_test.dart';
import 'package:tinla/domain/services/string_done_tracker.dart';

void _feed(StringDoneTracker tracker, int index, double cents, int frames) {
  for (var i = 0; i < frames; i++) {
    tracker.update(stringIndex: index, cents: cents);
  }
}

void main() {
  test('12 in-band frames are not done, the 13th makes string 1 done', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 2, 11);
    expect(tracker.update(stringIndex: 1, cents: 2), isEmpty);
    expect(tracker.update(stringIndex: 1, cents: 2), {1});
  });

  test('a frame at 6 cents resets the count', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 2, 12);
    tracker.update(stringIndex: 1, cents: 6);
    _feed(tracker, 1, 2, 12);
    expect(tracker.update(stringIndex: 1, cents: 2), {1});
  });

  test('exactly 5 cents is in band', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 0, -5, 12);
    expect(tracker.update(stringIndex: 0, cents: 5), {0});
  });

  test('done string survives 2 frames at 20 cents and drops on the 3rd', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 13);
    expect(tracker.update(stringIndex: 1, cents: 20), {1});
    expect(tracker.update(stringIndex: 1, cents: -20), {1});
    expect(tracker.update(stringIndex: 1, cents: 20), isEmpty);
  });

  test('a frame within the release band resets the release count', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 13);
    _feed(tracker, 1, 20, 2);
    tracker.update(stringIndex: 1, cents: 10);
    expect(tracker.update(stringIndex: 1, cents: 20), {1});
    expect(tracker.update(stringIndex: 1, cents: 20), {1});
    expect(tracker.update(stringIndex: 1, cents: 20), isEmpty);
  });

  test('exactly 15 cents does not release', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 13);
    _feed(tracker, 1, 15, 5);
    expect(tracker.update(stringIndex: 1, cents: 15), {1});
  });

  test('null frame breaks the count but keeps done strings', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 0, 0, 13);
    _feed(tracker, 1, 0, 12);
    expect(tracker.update(stringIndex: null, cents: null), {0});
    expect(tracker.update(stringIndex: 1, cents: 0), {0});
    _feed(tracker, 1, 0, 11);
    expect(tracker.update(stringIndex: 1, cents: 0), {0, 1});
  });

  test('null index or null cents alone is a null frame', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 12);
    tracker.update(stringIndex: 1, cents: null);
    expect(tracker.update(stringIndex: 1, cents: 0), isEmpty);
    _feed(tracker, 1, 0, 11);
    tracker.update(stringIndex: null, cents: 0);
    expect(tracker.update(stringIndex: 1, cents: 0), isEmpty);
  });

  test('null frame breaks the release count of a done string', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 13);
    _feed(tracker, 1, 20, 2);
    tracker.update(stringIndex: null, cents: null);
    expect(tracker.update(stringIndex: 1, cents: 20), {1});
  });

  test('switching string resets counters of the previous string', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 12);
    tracker.update(stringIndex: 2, cents: 0);
    tracker.update(stringIndex: 1, cents: 0);
    expect(tracker.update(stringIndex: 1, cents: 0), isEmpty);
  });

  test('two strings can be done at once', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 0, 0, 13);
    _feed(tracker, 3, 1, 12);
    expect(tracker.update(stringIndex: 3, cents: 1), {0, 3});
  });

  test('returned set is an unmodifiable copy', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 12);
    final done = tracker.update(stringIndex: 1, cents: 0);
    expect(() => done.add(9), throwsUnsupportedError);
    expect(tracker.update(stringIndex: 1, cents: 0), {1});
    expect(done, {1});
  });

  test('reset empties the set and the counters', () {
    final tracker = StringDoneTracker();
    _feed(tracker, 1, 0, 13);
    tracker.reset();
    expect(tracker.update(stringIndex: null, cents: null), isEmpty);
    _feed(tracker, 1, 0, 12);
    tracker.reset();
    expect(tracker.update(stringIndex: 1, cents: 0), isEmpty);
  });

  test('constructor validates arguments', () {
    expect(() => StringDoneTracker(holdFrames: 0), throwsArgumentError);
    expect(() => StringDoneTracker(doneBandCents: 0), throwsArgumentError);
    expect(() => StringDoneTracker(releaseCents: -1), throwsArgumentError);
    expect(() => StringDoneTracker(releaseFrames: 0), throwsArgumentError);
  });
}
