# Android release checklist

This document owns Android release operations. Contributor and UI rules live in
[AGENTS](../AGENTS.md); component/storage lookup and validation limits live in
[the implementation reference](../reference.md). The validation record below
describes the earlier stability build; rerun checks against the current checkout
after subsequent UI or behavior changes.

## Pending release highlights

The following highlights are included in prepared build 18 and remain unpublished
until the Play release is confirmed. Continue maintaining pending notes here;
[the release policy](../AGENTS.md#release-policy) governs versioning.

## Prepared release: 1.1.2 (18)

Prepared November 20, 2026. The user confirmed that 17 is the highest build number
uploaded across all Play tracks; build 18 is the next upload code. Keep product
version 1.1.2 because this continues the prepared patch release with startup and
UI polish, rather than adding a new product capability. Production publication
of the preceding builds has not been confirmed.

### User-facing notes

- Get ready to play with a clear welcome and loading screen.
- Switch instruments with one tap while recorded drums keep playing.
- Use compact landscape menus and a simpler saved-beat Library.
- Find the YMT logo and website link together in About.

### Verification status

- Implementation committed as `bdc05ca`; build metadata sets `1.1.2+18` and About remains `v1.1.2`.
- Flutter analysis is clean; 69 isolated UI tests and 10 isolated storage tests passed. Rendered dialog review covered English, Chinese, and Vietnamese, including larger text. These checks do not verify native audio or ads.
- Signed AAB generation and manifest/signing verification are pending. Artifact metadata will record its source commit and SHA-256 beside the versioned bundle in `build/releases/1.1.2-18/`.
- Physical-device startup, audio/backing-track continuity, saved-beat upgrade compatibility, and ads remain unverified. No upload or publication is authorized by this build request.

## Earlier prepared release: 1.1.2 (17)

Prepared November 20, 2026 at the user's request. Build 16 was uploaded, but Play
blocked review because landscape hardware was implicitly required. Build 17 is
the corrected replacement, not yet uploaded or published. Confirm no higher build
number has been consumed in Play Console before uploading.

Patch scope: restored existing practice controls, compact menus, consistent shared
presentation, and a menu website link. The four drum sounds and audio latency work
were already in the 1.1.1 source baseline and are not new 1.1.2 highlights.

### User-facing notes

- Keep recorded drums playing while switching to cymbals or gong.
- Choose drum sounds and adjust settings in compact landscape menus.
- Visit YMT Lion Dance from About.

### Verification status

- Product version and About label agree on 1.1.2; that artifact used build 17.
- Corrected build 17 is `build/releases/1.1.2-17/LionDanceKit-1.1.2-build17.aab`. Its SHA-256 is `a90126f93194186af04abbcc2993d3c09d41c2d63048cdf0ace94fda2ccc9380`. It includes the manifest/build-number correction on top of `a356eb0`; `source-changes.patch` and `build-info.json` beside it record that uncommitted delta.
- Inspected build 17's bundled manifest: landscape hardware explicitly has `required="false"`, the main activity retains `sensorLandscape`, and package/version/build are correct. Verified its JAR signature and expected upload certificate SHA1 `53:1B:10:76:0E:FF:11:9D:D3:F1:DA:16:1F:E1:7E:BF:8F:C0:E6:7C`. No APK was generated for this replacement.
- Shared-UI implementation passed Flutter analysis, web compilation, 48 isolated UI/storage tests, and representative rendered dialog review before the version-only update.
- Earlier build 16 AAB and APK were built November 20, 2026 from commit `a356eb0`. The AAB was uploaded and is superseded by corrected build 17; production publication has not been confirmed.
- Verified the AAB's package/version directly from its manifest and verified its JAR signature. Verified the APK with `aapt` and `apksigner`; both artifacts use package `com.DiepSigh.LionDanceKit` and the same signing certificate.
- Earlier signing investigation: build 16's local AAB copies matched the expected upload certificate; a reported rejection identified a different certificate (`8D:1C:7E:AA:FD:49:AF:8D:AB:2A:8D:26:3E:68:1A:94:CB:BA:2C:5A`). Historical build 16 file SHA-256: `4c8835549c17e5b92ac2bb649a48fe1893884e8bf092e9cccf761bed31f27be1`. This is a historical signing record; use the current prepared artifact above.
- Actual artifacts have minimum SDK 24 and target/compile SDK 36. This follows the current Flutter defaults, rather than the older project overview's API 37 claim.
- Versioned files and SHA-256 metadata are in `build/releases/1.1.2-16/`: `LionDanceKit-1.1.2-16.aab` for Play Console and `LionDanceKit-1.1.2-16.apk` for direct installation. `build-info.json` records hashes, signing identity, source commit, and verification limits. Build output is ignored by Git.
- Android tooling emitted future-version support warnings. JAR verification also reported the existing self-signed certificate and archive-layout warnings; APK v2 signature verification passed. Physical-device installation and Play Console validation have not been performed.
- Real-device audio/mixing/ad checks remain outstanding. No phone is connected; the local Pixel emulator cannot start because the acceleration driver is unavailable. The iOS AdMob App ID remains unconfigured.

## Prepare an approved release

1. Confirm the user has requested release preparation and establish the latest actually uploaded/published version and highest used build number in Play Console, across all tracks.
2. Review accumulated changes and pending highlights. Choose the product version by user impact (or use the exact requested version) and a higher unused store build number.
3. Set `version: MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`. Check/update the About label in `home_screen.dart` and the approved notes so they agree. Avoid unrecorded build-name/build-number overrides.
4. Run the checks below and verify the required physical-device practice/audio/ad workflow. Report unavailable checks instead of marking them passed.
5. Build the signed AAB, inspect its effective version name/code, and record the artifact's source commit and validation results in the release handoff. Do not assume a previous bundle in `build/` contains the latest changes.
6. On explicit authorization to upload/publish, test that exact artifact on the internal track, then promote the tested bundle. Rebuilding a corrected binary needs another unused increasing build number; promoting the same bundle does not.
7. Curate the pending highlights for that release. After publication is confirmed, retain its version/build and notes in this document's release history and remove only the highlights actually shipped. Do not publish or create Git release tags during ordinary implementation work.

## Stability update record: 1.1.1 (15)

The sections below retain the earlier stability update's engineering record and
release procedure. Its title/version is historical, not a request to upload build
15 again or a claim that these later interface changes have shipped.

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
5. Check drum, side drum, cymbals, gong, play/stop, recording, replay, saving/loading, and banner ads, including the required uninterrupted practice workflow in [AGENTS](../AGENTS.md).
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
