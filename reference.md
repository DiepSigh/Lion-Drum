# Lion Dance Kit implementation reference

This is the technical lookup for the active Flutter app. [AGENTS.md](AGENTS.md)
owns contributor rules, UI consistency policy, and the required practice workflow.
[Flutter setup](flutter/README.md) owns commands and browser configuration;
[the release checklist](flutter/RELEASE_CHECKLIST.md) owns release operations.

## Architecture and file lookup

| Path | Responsibility |
| --- | --- |
| `flutter/lib/main.dart` | Restore locale, request immersive landscape orientation, apply the shared Material theme, and start the app |
| `flutter/lib/home_screen.dart` | Coordinate audio initialization, ads, selected instrument, dialogs, saved beats, and recording/replay ticker |
| `flutter/lib/soundboard.dart` | SoLoud lifecycle, instrument playback/muting, recording timestamps, and drum replay |
| `flutter/lib/saved_beat.dart` | Validate recordings and save/load named beats on mobile or in browser storage |
| `flutter/lib/instrument_surface.dart` | Original bottom-centered instrument geometry, pointer-down/multitouch hit detection, and strike feedback |
| `flutter/lib/performance_controls.dart` | Upper controls, shared transport, and reserved ad slot |
| `flutter/lib/ui/kit_styles.dart` | Shared palette, control sizes, dialog spacing, button styles, and Material theme |
| `flutter/lib/ui/kit_dialog.dart` | Compact dialog shell using Flutter focus/dismissal behavior and a scrolling fallback |
| `flutter/lib/ui/kit_button.dart` | Dialog and toolbar actions with shared styles and native semantics |
| `flutter/lib/saved_beats_dialog.dart` | Content-sized Library shell and bounded scrolling; caller owns sorting and saved-beat actions |
| `flutter/lib/app_info_dialogs.dart` | Menu/About presentation; callers own navigation and website launching |
| `flutter/lib/ui/kit_startup_cover.dart` | Opaque startup presentation; keeps the underlying practice screen inert while it prepares |
| `flutter/lib/l10n/app_*.arb` | English, Simplified Chinese, and Vietnamese translation sources |
| `flutter/lib/l10n/app_localizations*.dart` | Generated localization output; regenerate rather than editing manually |
| `flutter/test/performance_ui_test.dart` | Practice controls, translations, ad separation, layout constraints, and two-thumb hit regression coverage |
| `flutter/test/shared_ui_test.dart` | Compact shared-dialog layout/action contracts across locales; optional rendered review fixtures |
| `flutter/test/saved_beat_test.dart` | Recording validation and saved-beat persistence regression coverage |

Instrument modes are Drum (0), Cymbals (1), and Gong (2). Drum replay is independent
of the selected live instrument. The ticker updates recorded drum playback each
frame and refreshes its status periodically. Recording uses a stopwatch; only
drum/side strikes are recorded. The storage limit and validation rules live in
`SavedBeatLimits`; beat types are 0 for drum and 1 for side.

SoLoud initializes and shuts down asynchronously. Shutdown waits for in-flight
initialization. Cymbal and gong voices have their own handle collections so muting
a live instrument does not stop the drum backing track. Playback flashes are only
shown on the Drum surface; live strikes flash the current surface.

Saved beats use the application documents directory on mobile and
`SharedPreferences` on web. Browser storage is specific to the browser and origin.
Loading a beat replaces the current recording after the existing unsaved-recording
confirmation. The Library is accessible in every mode before a beat is loaded;
playback must be stopped before loading a replacement.

## Shared UI library and reviewed decisions

The reusable-library approach is adapted from LionBase (`lion-ops`)'s shared
styles, action controls, modal shell, and UI consistency policy. This app uses
Flutter Material 3 components; LionBase's React/Tailwind modules are not runtime
dependencies. The approved percussion appearance is owned by `KitStyles`.

| Surface or choice | Reviewed behavior and implementation |
| --- | --- |
| Appearance | Dark burgundy surfaces, gold accents, restrained borders; colors and repeated dimensions live in `KitStyles` |
| Startup | Opaque burgundy/gold `KitStartupCover` blocks pointer, focus, and practice semantics while the main screen renders underneath. The welcome screen stays visible for at least three seconds from its first frame, alongside startup. Reveal also waits for audio, saved-beat loading, image precaching, and a painted frame. The first ad outcome has a five-second budget starting alongside audio; timeout/failure does not prevent practice, and a late banner can still appear. Audio failure retains the retry screen |
| Background | Original `assets/images/final.jpg`, subdued over the burgundy gradient; decorative and excluded from hit testing/semantics |
| Playing surface | Original diameter `min(width * 0.95, height * 2) * 5 / 9`, centered at `(width / 2, height)`; the surrounding surface is the side/mute zone |
| Touch handling | Sounds trigger on pointer down; simultaneous thumbs work; toolbar, dialogs, and the empty ad reservation do not trigger percussion |
| Ad space | Top center reserves a 320 x 50 standard banner, including before load/failure. Rails move below it at narrow usable widths |
| Toolbar | Shared `KitToolbarButton`; 44px minimum height, full tooltip/accessibility text, visible disabled states, and reserved bottom thumb zones |
| Instrument switch | Shared `KitToolbarButton` cycles Drum → Cymbals → Gong → Drum directly on each tap, with a cycle icon and current-instrument label; available during playback without changing the backing track, disabled while recording |
| Transport | Play/Stop and Library in every mode. Record and Save remain on Drum. The backing rhythm continues when switching or striking/muting another instrument |
| Menu | Shared compact `AppMenuDialog`; centered title with About and Language actions |
| About | Shared compact `AppAboutDialog`; centered translated app title, 40px YMT logo beside the version, description, full-width Visit YMT Lion Dance button, copyright, and a standard close action. Larger text retains the shared scrolling fallback |
| Drum sound | Shared centered heading and compact dialog with a 2 x 2 grid; tapping Original/Deep/Warm/Tight selects and previews the sound; selection remains visible |
| Language | Compact three-choice dialog; selection persists per device/browser |
| Dialog headings | All app dialogs use `KitDialogHeading`: centered 16px gold text from the single `KitStyles.dialogHeading` style, including Menu, About, Sound, Library, Language, naming, and confirmations. Library retains tighter title padding; it does not use a different heading size. Library filter typography also lives in `KitStyles` |
| Dialog shell | `KitDialog` owns title/content/action spacing, surface, and shape. Flutter's `showDialog` owns focus, Escape/back, and dismissal. Callers own workflow guards and persistence |
| Library | Centered 16px Saved Beats title with compact title padding; dense filter uses 12px label/selection text and a roughly 32px closed box, with a 4px gap before beats. This user-requested compact Library filter is an additional size exception; open dropdown choices retain native 48px rows and larger text can expand the box; content-sized body with bounded scrolling for longer lists, filter and existing row actions, and Close outside the body. Save Current is omitted; use the Drum toolbar Save action |
| Scrolling | Ordinary selectors/menu should fit a short landscape screen. Shared dialogs can scroll for larger text; Library grows and scrolls internally with its closing action outside the body |
| Branding link | YMT logo and website action live in About; the button launches `https://www.ymtliondance.com/`. Image origin is in `flutter/assets/images/ymt-logo.source.txt` |
| Compact exception | Saved-beat row actions retain their established 32px visual size through `KitStyles.smallDialogButton`; review touch comfort before changing row layout |
| Localization | New copy belongs in all three ARB files; source headings retain natural/Title Case and user-entered beat names are unchanged |

Keep the table current when the user reviews a new interaction or visual choice.
Policy belongs in AGENTS; this table records its current implementation. Known
structural follow-up: `home_screen.dart` still combines workflow coordination and
several dialog bodies. Extract those by responsibility when their behavior is next
changed; do not split or rewrite the audio state machine during a style-only task.

## Assets and platform integration

`pubspec.yaml` owns asset registration and dependency versions. SoLoud provides
low-latency audio; `google_mobile_ads` provides mobile banners; `url_launcher`
handles the website action. Ad initialization is deferred by `HomeScreen` and is
skipped on web. App identifiers must continue matching the published store listing.

The Android manifest owns the AdMob app ID; the platform banner unit IDs are in
`home_screen.dart`. The iOS banner currently uses Google's test unit. Replace the
iOS App ID/unit and verify the iOS minimum deployment target before publishing
there; use the release checklist for operational steps rather than copying them.

Android's `sensorLandscape` activity setting implies a required landscape feature
for Play filtering unless explicitly overridden. The app manifest declares
`android.hardware.screen.landscape` with `android:required="false"` so the practice
layout does not unnecessarily exclude devices. Preserve that declaration when
editing orientation settings, and verify it in the built bundle's manifest.

## Validation and honest limits

The layout regression suite exercises 432 x 320, 568 x 320, and 844 x 390 logical
sizes with larger text and all supported locales. These are usable viewport sizes,
not guarantees about particular devices. Shared dialog changes should also be
reviewed at 568 x 320 with menu, language, sound selection, and confirmation states
open. Check initial/selected/disabled states, keyboard focus, and long translations.
`shared_ui_test.dart` can export fixtures with `--dart-define=UI_REVIEW_DIR=<path>`;
its optional `UI_REVIEW_FONT_DIR` loads local SDK fonts for readable review PNGs.
These fixtures review the shared shell and representative content, not native
audio or the complete running app. SDK Latin fonts alone do not verify Chinese
glyph rendering; review that locale with an appropriate font/device too.

Compile/analyzer results establish code validity, not visual consistency or
perceived audio latency. Compare rendered comparable surfaces before claiming
visual verification. If visual review or device testing could not run, say so.

On this Windows environment, the audio plugin's native test build requires the
Visual Studio C++ toolchain. When unavailable, UI and saved-beat tests can run in
an isolated test harness using copies of the actual app UI/storage sources and
locked dependency versions, excluding the audio/ad plugins. Label those results
as isolated tests: they do not verify native audio mixing, device lifecycle, or
live ad delivery. The ignored `.dart_tool` harness is disposable and must be
resynchronized from the source files before each run.

The web preview validates browser UI and storage. Adding/changing plugins may
require stopping and relaunching the preview, beyond hot reload. Browser autoplay,
popup behavior, and worker headers differ from a phone; use the browser setup
instructions and the phone practice check in AGENTS before release.

## Release documentation

The version policy is in [AGENTS](AGENTS.md#release-policy); pending user-facing
highlights and the upload/promotion steps belong to the existing
[release checklist](flutter/RELEASE_CHECKLIST.md). This follows LionBase's separate
pending/published release-note discipline, adapted to a native Play distribution.

### Version sources and Android mapping

| Value | Owner and use |
| --- | --- |
| Product version | The three-part value before `+` in `flutter/pubspec.yaml`; becomes Android `versionName` |
| Store build number | The positive integer after `+`; becomes Android `versionCode`, increasing independently of product version |
| Gradle wiring | `flutter/android/app/build.gradle.kts` reads `flutter.versionName` and `flutter.versionCode`; keep that mapping |
| About label | Currently the literal `v1.1.2` in `home_screen.dart`; update/check it when preparing an approved release |
| Generated Android metadata | `flutter/android/local.properties` is build output/configuration, not the release version source |
| Browser preview | Same app source/product version; useful for development and UI checks, not a delivery mechanism for installed Android app code |

For example, `1.2.0+16` would mean product version `1.2.0` and Play build `16`.
This is an example, not an approved next version or a statement that build 16 is
unused. Verify the actual uploaded versions in Play Console before reserving a
number; repository metadata alone cannot establish that.

Use the same product version for test rebuilds of one intended release while
advancing the build number for each new uploaded binary. Promote a tested bundle
between tracks without rebuilding it merely to change tracks. A corrected binary
requires another unused higher build number. Preserve the historical mapping of
versions to published artifacts; do not relabel shipped versions.

Flutter supports `--build-name` and `--build-number` overrides. Prefer the approved
`pubspec.yaml` values; if an override is intentionally used, record the effective
name/code with the artifact and verify About agrees with what was actually built.
Do not silently leave source, displayed version, and uploaded metadata different.

### Release scope and notes

The installed app contains Flutter's compiled UI/audio code and bundled assets.
Changes to those require a rebuilt signed Android bundle and an approved Play
release. The LionBase web-wrapper practice of updating the live site independently
does not deliver these changes to Lion Dance Kit installations.

Assess the full scope since the previous published release, including pending
highlights and relevant commits. Styling and consistency changes alone are patch
scope; meaningful new capabilities are minor scope; a substantial change to how
people use the product can warrant major scope. Follow an exact user-supplied
version and explain the chosen bump when preparing a release.

Public notes should normally contain 3–6 short user-facing highlights, fewer when
appropriate. Merge related polish; keep significant new capabilities, required
actions, and important data/policy notices distinct. Do not expose component names,
test harnesses, plugin plumbing, or a list of individual spacing fixes to users.
Keep those details in commits and this reference. Edit the complete set of notes
before publication, remove already-shipped items, and only mark a release published
after its actual publication is confirmed.

Platform sources: [Flutter Android version mapping](https://docs.flutter.dev/deployment/android#update-the-apps-version-number)
and [Android versioning requirements](https://developer.android.com/studio/publish/versioning).
