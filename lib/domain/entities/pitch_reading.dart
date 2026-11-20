/// One analysis frame from the pitch detector.
class PitchReading {
  const PitchReading({
    required this.frequency,
    required this.clarity,
    required this.level,
  });

  /// Detected fundamental in Hz.
  final double frequency;

  /// Detector confidence, 0 to 1.
  final double clarity;

  /// RMS of the analysed window, 0 to 1.
  final double level;
}
