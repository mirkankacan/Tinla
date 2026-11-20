# Tınla

A guitar and bağlama (saz) tuner for Android, built with Flutter.
Gitar ve bağlama için Android akort uygulaması.

> **Status: in development.** Nothing here is released yet. / Geliştirme aşamasında, henüz yayınlanmadı.

## What it does

Tınla listens through the microphone, works out which string you played and shows how many cents sharp or flat it is.

- Guitar: 11 tunings (Standard, Drop D, DADGAD, open tunings, ...).
- Bağlama: 10 düzen (Bozuk, Bağlama Düzeni, Misket, Müstezat, ...), long-neck and short-neck (uzun sap / kısa sap).
- Automatic string detection, with a manual lock by tapping a tuning peg.
- Planned: a free tier and a one-time Pro purchase.

## Tech

Flutter 3.50 / Dart 3.14, Android only. Clean Architecture (`presentation → domain ← data`), checked by `test/architecture_test.dart`. Microphone input with `record`, pitch detection with YIN (`pitch_detector_dart`), state with Riverpod.

## Develop

```
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The bağlama düzen notes come from Karahan & Doğan, *Online Journal of Music Sciences* 2025, 10(3), 678–702. Entries that are not yet verified against their source are marked `UNVERIFIED` in the code.

Design references live in `docs/design/`.

## License

No license has been granted yet. All rights reserved for now. / Henüz bir lisans verilmedi, tüm haklar saklıdır.
