# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**Lion Dance Kit** (v1.0.0) — a Flutter mobile app for Android and iOS that simulates lion dance percussion instruments (drum, side drum, cymbals, gong). Users can record beat sequences and replay them.

- Company: DiepSigh
- Flutter version: 3.41.6 (stable)
- Target platforms: Android (API 37), iOS (16.0+)
- Package name: `com.DiepSigh.LionDanceKit` (must match existing Play Store listing)

## Project Structure

```
Lion-Drum/
├── flutter/          ← active Flutter project
│   ├── lib/
│   │   ├── main.dart         — entry point, AdMob init
│   │   ├── soundboard.dart   — audio engine + record/replay logic
│   │   └── home_screen.dart  — full UI (3 instrument modes)
│   ├── assets/
│   │   ├── sounds/   — drum.wav, side.wav, cymbal.wav, cymbal2.wav, gong2.wav
│   │   └── images/   — final.jpg (background), LionIcon.png
│   └── android/app/src/main/AndroidManifest.xml
├── legacy/
│   └── unity-reference/ ← selected Unity source/scene files kept for historical reference
└── AGENTS.md
```

## Building and Running

```bash
cd flutter
flutter pub get
flutter run                    # run on connected device
flutter build apk --release    # Android release build
flutter build ios              # iOS (requires Mac)
```

## Architecture

**`soundboard.dart`** — Core logic (ported from Unity `SoundBoard.cs`). Uses `flutter_soloud` (SoLoud C++ engine) for low-latency audio. Manages four sounds (drum, side, cymbal, gong). Handles recording and replay of beat sequences stored as parallel arrays: `_beatTimes[3000]` (timestamps) and `_beatTypes[3000]` (0=drum, 1=side). `update(dt)` is called each frame during replay via a Flutter `Ticker`.

**`home_screen.dart`** — UI state manager (ported from Unity `UIToggle.cs`). Cycles through three instrument modes: Drum (0), Cymbals (1), Gong (2). Drum mode supports record/replay; Cymbals and Gong have play/stop buttons only.

**`main.dart`** — Entry point. Initializes AdMob, locks to lockscape orientation.

### Key Design Notes

- Instrument cycle: Drum → Cymbals → Gong → Drum. Record/replay only available in Drum mode.
- Recording is mutually exclusive with replay.
- Replay uses a Flutter `Ticker` (fires every frame) to call `soundboard.update(dt)`.
- Cymbal and gong track their active `SoundHandle` so they can be stopped mid-play.

## Dependencies

- **`flutter_soloud` ^4.0.2** — low-latency audio (SoLoud engine)
- **`google_mobile_ads` ^8.0.0** — AdMob banner ads
- Android ad unit ID: `ca-app-pub-7760662598407173~6261911664`
- iOS ad unit ID (test): `ca-app-pub-3940256099942544/2934735716`

## TODO Before Publishing

- [ ] **iOS AdMob App ID** — add real `GADApplicationIdentifier` to `flutter/ios/Runner/Info.plist`
- [ ] **iOS ad unit ID** — replace test ID with real iOS ad unit ID in `home_screen.dart`
- [ ] **iOS minimum version** — set to 16.0 in Xcode project settings
