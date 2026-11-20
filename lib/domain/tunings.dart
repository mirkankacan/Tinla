import 'entities/note.dart';
import 'entities/tuning.dart';

// Midi: C2 = 36, E2 = 40, A2 = 45.
const _guitarTunings = <Tuning>[
  Tuning(
    id: 'standard',
    name: 'Standard',
    instrument: Instrument.guitar,
    isFree: true,
    strings: [
      TuningString(Note(40), 'E2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(59), 'B3'),
      TuningString(Note(64), 'E4'),
    ],
  ),
  Tuning(
    id: 'half-step-down',
    name: 'Half Step Down',
    instrument: Instrument.guitar,
    isFree: true,
    strings: [
      TuningString(Note(39), 'Eb2'),
      TuningString(Note(44), 'Ab2'),
      TuningString(Note(49), 'Db3'),
      TuningString(Note(54), 'Gb3'),
      TuningString(Note(58), 'Bb3'),
      TuningString(Note(63), 'Eb4'),
    ],
  ),
  Tuning(
    id: 'whole-step-down',
    name: 'Whole Step Down',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(43), 'G2'),
      TuningString(Note(48), 'C3'),
      TuningString(Note(53), 'F3'),
      TuningString(Note(57), 'A3'),
      TuningString(Note(62), 'D4'),
    ],
  ),
  Tuning(
    id: 'drop-d',
    name: 'Drop D',
    instrument: Instrument.guitar,
    isFree: true,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(59), 'B3'),
      TuningString(Note(64), 'E4'),
    ],
  ),
  Tuning(
    id: 'double-drop-d',
    name: 'Double Drop D',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(59), 'B3'),
      TuningString(Note(62), 'D4'),
    ],
  ),
  Tuning(
    id: 'dadgad',
    name: 'DADGAD',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(57), 'A3'),
      TuningString(Note(62), 'D4'),
    ],
  ),
  Tuning(
    id: 'open-g',
    name: 'Open G',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(43), 'G2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(59), 'B3'),
      TuningString(Note(62), 'D4'),
    ],
  ),
  Tuning(
    id: 'open-d',
    name: 'Open D',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(38), 'D2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(50), 'D3'),
      TuningString(Note(54), 'F#3'),
      TuningString(Note(57), 'A3'),
      TuningString(Note(62), 'D4'),
    ],
  ),
  Tuning(
    id: 'open-e',
    name: 'Open E',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(40), 'E2'),
      TuningString(Note(47), 'B2'),
      TuningString(Note(52), 'E3'),
      TuningString(Note(56), 'G#3'),
      TuningString(Note(59), 'B3'),
      TuningString(Note(64), 'E4'),
    ],
  ),
  // Wikipedia "Open A" main form is E-A-C#-E-A-E; the brief's E-A-E-A-C#-E is
  // the slide variant listed there.
  Tuning(
    id: 'open-a',
    name: 'Open A',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(40), 'E2'),
      TuningString(Note(45), 'A2'),
      TuningString(Note(49), 'C#3'),
      TuningString(Note(52), 'E3'),
      TuningString(Note(57), 'A3'),
      TuningString(Note(64), 'E4'),
    ],
  ),
  Tuning(
    id: 'open-c',
    name: 'Open C',
    instrument: Instrument.guitar,
    strings: [
      TuningString(Note(36), 'C2'),
      TuningString(Note(43), 'G2'),
      TuningString(Note(48), 'C3'),
      TuningString(Note(55), 'G3'),
      TuningString(Note(60), 'C4'),
      TuningString(Note(64), 'E4'),
    ],
  ),
];

// Source: Karahan & Doğan, Online Journal of Music Sciences 2025, 10(3),
// 678-702. Octaves are arbitrary (matching is octave-folded); each düzen is
// stored strictly ascending starting at A2.
const _baglamaTunings = <Tuning>[
  Tuning(
    id: 'baglama-bozuk',
    name: 'Bozuk',
    instrument: Instrument.baglama,
    isFree: true,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(50), 'Re (D)'),
      TuningString(Note(55), 'Sol (G)'),
    ],
  ),
  Tuning(
    id: 'baglama-duzeni',
    name: 'Bağlama Düzeni',
    instrument: Instrument.baglama,
    isFree: true,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(50), 'Re (D)'),
      TuningString(Note(52), 'Mi (E)'),
    ],
  ),
  Tuning(
    id: 'baglama-evc',
    name: 'Evc',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(47), 'Si (B)'),
      TuningString(Note(55), 'Sol (G)'),
    ],
  ),
  Tuning(
    id: 'baglama-misket',
    name: 'Misket',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(50), 'Re (D)'),
      TuningString(Note(54), 'Fa♯ (F#)'),
    ],
  ),
  Tuning(
    id: 'baglama-mustezat',
    name: 'Müstezat',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(50), 'Re (D)'),
      TuningString(Note(53), 'Fa (F)'),
    ],
  ),
  Tuning(
    id: 'baglama-rast',
    name: 'Rast',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(48), 'Do (C)'),
      TuningString(Note(55), 'Sol (G)'),
    ],
  ),
  Tuning(
    id: 'baglama-segah',
    name: 'Segâh',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(50), 'Re (D)'),
      TuningString(Note(59), 'Si (B)'),
    ],
  ),
  Tuning(
    id: 'baglama-sur',
    name: 'Şûr',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(52), 'Mi (E)'),
      TuningString(Note(59), 'Si (B)'),
    ],
  ),
  Tuning(
    id: 'baglama-zirgule',
    name: 'Zirgüle',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(53), 'Fa (F)'),
      TuningString(Note(55), 'Sol (G)'),
    ],
  ),
  // Abdal (also called Bozlak) is La La Sol. Verified 2026-11-21 against
  // Kirsehir KTB "Bozlak nedir", Turkuler (Baglamanin Tarihi), the Lokman Bas
  // tuning table ("Bozlak Duzeni La La Sol") and the MEB module table row
  // "LA LA SOL".
  Tuning(
    id: 'baglama-abdal',
    name: 'Abdal',
    instrument: Instrument.baglama,
    strings: [
      TuningString(Note(45), 'La (A)'),
      TuningString(Note(57), 'La (A)'),
      TuningString(Note(67), 'Sol (G)'),
    ],
  ),
];

const List<Tuning> allTunings = [..._guitarTunings, ..._baglamaTunings];

List<Tuning> tuningsFor(Instrument instrument) => List.unmodifiable(
  allTunings.where((tuning) => tuning.instrument == instrument),
);

Tuning get standardTuning => _guitarTunings.first;

Tuning defaultTuningFor(Instrument instrument) => switch (instrument) {
  Instrument.guitar => standardTuning,
  Instrument.baglama => _baglamaTunings.first,
};
