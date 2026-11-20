# Lion Dance Kit development

The active Flutter project supports Android and iOS, with a browser preview for UI
and storage work. Start with the repository [documentation index](../README.md),
[contributor/UI rules](../AGENTS.md), and [implementation reference](../reference.md).

## Local development

Use the SDK required by `pubspec.yaml` and the current audio plugin. From this
`flutter/` directory:

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
```

On Windows, the audio plugin's host test build requires Visual Studio C++ tools.
See [validation limits](../reference.md#validation-and-honest-limits) for isolated
UI/storage testing and its limitations. Build/release commands and store testing
belong to the [release checklist](RELEASE_CHECKLIST.md).

## Browser preview

Run the app in Chrome with the audio worker's required headers:

```powershell
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

Use `-d edge` for Microsoft Edge. Click an instrument to allow browser audio.
Press `r` for hot reload or `R` to restart Dart state. After adding a plugin, fully
stop and relaunch `flutter run` so platform registration is regenerated, then
refresh the browser. If a website launch still fails, inspect the browser console
rather than assuming it is mobile-only.

Saved beats and the selected language are stored in this browser. Keep the same
hostname, port, and browser to reuse them. Clearing browser site data clears them.
AdMob is skipped in browser previews. Use a phone for audio latency, live mixing,
multitouch, lifecycle, and ad checks; see the required practice workflow in AGENTS.

To compile the web preview:

```powershell
flutter build web
```

## Translation and shared UI changes

Edit `lib/l10n/app_en.arb`, `app_zh.arb`, and `app_vi.arb`, then regenerate:

```powershell
flutter gen-l10n
dart format lib test
flutter analyze
```

Use the existing components/tokens under `lib/ui/` for repeated presentation. The
[reviewed UI table](../reference.md#shared-ui-library-and-reviewed-decisions) records
current choices; AGENTS owns the policy for changing them.
