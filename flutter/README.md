# lion_dance_kit

## Browser preview

From this directory, run the app in Chrome.

```powershell
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

Use `-d edge` for Microsoft Edge. The headers enable SoLoud's audio worker.
Press `r` in the terminal to hot reload changes or `R` to restart the app.
Click an instrument to allow the browser to start audio playback.

Saved beats and the selected language are stored in this browser. Keep the
same hostname, port, and browser to reuse them across runs. Clearing browser site data
also clears saved beats. AdMob is skipped in browser previews.

Use a phone for final checks of audio latency, multitouch, and ads.

To build the web app, run `flutter build web`.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
