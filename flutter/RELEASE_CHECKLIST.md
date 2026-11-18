# Android stability update: 1.1.1 (15)

## Changes

- Upgrade flutter_soloud from 4.0.2 to 5.1.6 for native callback and audio-device lifecycle fixes.
- Start audio and ads after the loading screen's first frame.
- Initialize ads without delaying runApp.
- Handle failed audio initialization with a localized retry screen.
- Wait for in-flight audio initialization before shutting down the engine; let the engine release its sources and callbacks in order.
- Guard late ad callbacks after the screen closes.

## Build

Use Flutter 3.47.6 stable or a compatible newer stable SDK. Flutter 3.41.6 cannot resolve the updated audio plugin's build dependencies.

From the flutter directory:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Output: build/app/outputs/bundle/release/app-release.aab

On Windows, `flutter test` also builds the audio plugin for the host and requires the Visual Studio Desktop development with C++ workload. This does not prevent Android builds, which use the Android NDK. The existing 10 saved-beat tests were run against the app source in an isolated harness without the audio dependency.

Version code 15 must be unused in Play Console. If it has already been uploaded, increment the number after the + in pubspec.yaml and rebuild.

## Test through Google Play

1. Open Lion Dance Kit in Play Console, then Test and release > Testing > Internal testing.
2. Create a release and upload the AAB. Use release notes: "Improved startup reliability and audio stability."
3. Publish to internal testing and install from the tester opt-in link using a tester account.
4. Update an existing installation. Verify saved beats and language preferences survive.
5. Check drum, side drum, cymbals, gong, play/stop, recording, replay, saving/loading, and banner ads.
6. Repeatedly cold-launch and reopen the app. Try rapid tapping, background/resume while playing or loading, and switching between speaker, wired headphones, and Bluetooth where available. Include phone models listed in the ANRs.
7. Check the pre-launch report. Local tests and a successful build do not prove that a production ANR is fixed.

## Validation performed

- Flutter 3.47.6 / Dart 3.13.5; flutter_soloud resolved to 5.1.6.
- Verified the installed plugin uses Isolate.run for blocking native engine/device initialization and asynchronous engine teardown before releasing native callbacks.
- flutter analyze: no issues.
- Existing saved-beat regression suite: 10 tests passed in the isolated harness against the app's actual saved_beat.dart.
- Signed release AAB built successfully for 1.1.1 (15).
- No Android device was connected; playback and lifecycle testing on a real phone is still required.

## Publish and monitor

1. Promote the tested bundle to production, using a staged rollout where practical.
2. In Android vitals > Crashes and ANRs, filter to version code 15 and dates after rollout.
3. Track the deleted-callback SIGABRT and the AAudio initialization/no-focused-window ANR separately. Check affected users and devices, not only total event counts.
4. Compare the new version's rates with version 14. Android vitals updates daily; old-version reports can continue while users have not updated. Sparse data is not proof of a fix.
5. Expand the rollout if testing and new-version reports are healthy. Halt it if the new release introduces a serious regression.

## Remaining investigation

- Dashboard recommendations are attached to the release named "1.0.0 – Initial Production Release". Recheck their affected version codes after uploading version 15.
- R8 optimization is already enabled for version 15: the build produced mapping/configuration/usage reports with no dontoptimize, dontshrink, or dontobfuscate directives. No additional R8 change is needed for this bundle.
- Check edge-to-edge layout on Android 15/16, including camera cutouts, gesture navigation, banner ads, and dialogs. The current app requests immersiveSticky; changing that display behavior requires layout verification. If the deprecated-API warning persists for version 15, inspect Play Console's exact class/method list before choosing an app, Flutter, or dependency fix.
- The idle-main-thread nativePollOnce ANR has no established cause from the supplied sample. Review other samples if it persists on the new version.
- Review additional reports after this update before expanding scope.

References:

- https://github.com/alnitak/flutter_soloud/blob/main/CHANGELOG.md
- https://support.google.com/googleplay/android-developer/answer/9859348
- https://support.google.com/googleplay/android-developer/answer/6346149
- https://support.google.com/googleplay/android-developer/answer/9844486
