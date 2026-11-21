# AGENTS.md

Contributor guidance for Lion Dance Kit (DiepSigh). Read this file before changes;
use [reference.md](reference.md) for implementation lookup and reviewed UI choices.
The active application is Flutter in `flutter/`; legacy Unity files are historical.

## Documentation ownership

| File | Authoritative purpose |
| --- | --- |
| `AGENTS.md` | Assistant rules, UI policy, core practice invariants, and contribution conventions |
| `reference.md` | File/component lookup, technical behavior, reviewed UI decisions, integration details, and validation limits |
| `flutter/README.md` | Local setup, commands, and browser preview troubleshooting |
| `flutter/RELEASE_CHECKLIST.md` | Android release build, internal testing, publishing, and operational follow-up |
| `README.md` | Entry point linking to the owning documents |

Keep one authoritative home per topic. Update its owning section in the same change
as the behavior, and link elsewhere rather than copying facts or checklists. Do not
create a Markdown file for each task or release when an existing section fits.
Keep this file as the active instruction source. When moving documentation, repair
links and preserve workflow, permission, and release safeguards. If instructions
conflict with current code or a user's reviewed decision, resolve the discrepancy
before relying on stale assumptions; ask when the intended behavior is unclear.

## Project constraints

- Current project version: 1.1.2, with the authoritative version/build in `flutter/pubspec.yaml`.
- Project SDK guidance: Flutter 3.47.6 stable; use a compatible SDK for the current dependencies.
- Android compile/target SDK follows the Flutter defaults in Gradle; verify the built manifest rather than assuming an API level. The current artifact values are recorded in the release checklist. iOS targets 16.0+; verify the actual Xcode deployment target before an iOS release.
- Package name: `com.DiepSigh.LionDanceKit`; preserve the existing Play Store identity.
- Keep landscape, immersive play and low-latency pointer-down/multitouch handling.
- Keep recording/storage validation and saved-beat compatibility when refactoring.
- See Flutter setup for commands and the release checklist for publishing prerequisites, including the real iOS AdMob App ID and banner unit.

## Core practice workflow — preserve in every UI or audio change

- Playing cymbals or gong over a recorded drum beat is a core purpose of the app.
- Library and drum Play/Stop must be accessible in every instrument mode. Library must be usable before any recording is loaded; stop replay before loading a different saved beat.
- Instrument switching remains available during replay. It must not stop, restart, or change the backing track's timing.
- Live strikes and muting of cymbals/gong work alongside replay. Muting the live instrument must not stop the drum track.
- Recording is exclusive to Drum mode and mutually exclusive with replay. Keep switching disabled while recording.
- Preserve the original bottom-centered drum geometry, two-thumb side/main hit zones, and reserved top-center ad area. Chrome, dialogs, and empty ad reservations must not trigger percussion.
- Maintain focused regression coverage for these controls and all supported translations in `flutter/test/performance_ui_test.dart` when changing their behavior.
- Before release, verify on a phone: load a saved beat from Cymbals mode, start replay, strike/mute cymbals, switch to Gong while replay continues, strike/mute gong, then stop the drum track. The rhythm must continue uninterrupted until explicitly stopped or naturally completed.

## UI consistency policy

This policy adopts LionBase (`lion-ops`)'s shared-component and reviewed-UI approach,
adapted to this app's Flutter/Material stack and landscape practice workflow.

- Before adding/changing UI, inspect at least two comparable existing surfaces and the shared library in `flutter/lib/ui/`. Follow reviewed decisions in `reference.md`; extend a shared component before adding a one-off pattern. This includes small menus, toolbar actions, settings, and confirmation dialogs.
- Use `KitStyles` for repeated colors, sizes, spacing, button styles, and the app theme. Use `KitDialog`, `KitDialogButton`, and `KitToolbarButton` for their established roles. Use Flutter Material icons/native controls rather than introducing another icon or component system for an isolated feature.
- UI refactors include shared-component adoption and consistency in the affected scope. Compare rendered spacing, alignment, states, and close/actions across comparable surfaces; builds and functional tests alone do not prove visual consistency. Report unreviewed surfaces and remaining exceptions clearly.
- Keep the approved dark burgundy/gold appearance and compact landscape controls. Do not import LionBase's React/Tailwind code, navy palette, portrait bottom sheets, or light-mode requirements as a product change without a reviewed need.
- Prefer compact layouts that expose normal menu/selector choices without scrolling on a short landscape screen. The four drum sounds use a 2 x 2 grid. Library content may grow and scroll; its close action must remain reachable. Large text and small viewports retain a scroll fallback rather than clipping controls or shrinking text to fit.
- Shared dialogs own presentation and native focus/dismissal behavior; callers own state, preview/save/load actions, and unsaved/busy guards. Preserve existing confirmation behavior and keyboard/back navigation during extraction.
- Keep one clear title per panel, nearby helper text, consistent actions, visible selected/disabled states, and meaningful accessible labels. Source headings use natural/Title Case; do not force uppercase on names, translations, or sentences.
- Preserve comfortable touch targets (44px toolbar controls, 48px sound choices), safe areas, and the ad reservation. Existing compact Library row actions are a documented exception, not a default for new settings controls.
- All new app-facing copy belongs in English, Simplified Chinese, and Vietnamese ARB sources. Regenerate localizations; do not edit generated classes or translate user-entered beat names.
- Document newly reviewed choices in the existing UI decision table in `reference.md` as part of the implementation. Record the rule here only when it changes policy. Flag unrelated visual inconsistencies rather than silently redesigning other surfaces.

## Architecture and maintenance

- Keep audio/recording logic, persistence, shared presentation, and workflow coordination separate. Reuse `soundboard.dart`, `saved_beat.dart`, and the UI library rather than duplicating their responsibilities.
- Preserve asynchronous audio startup/shutdown and guards for late callbacks. UI extraction must not change the playback clock, sound handles, recording data, or initialization order.
- Prefer focused extractions when a file becomes mixed-purpose or approaches 1000 lines. Flag maintainability issues with the smallest useful improvement; do not turn a local UI task into an unrelated state-management rewrite.
- Add concise purpose/invariant comments to shared components and non-obvious synchronization. Avoid comments that merely restate individual statements.
- Keep startup, assets, and rendering efficient for mobile practice and low latency. Browser preview behavior does not establish mobile audio/ad behavior.

## Validation and completion

- Run focused checks appropriate to the change; use Flutter setup for commands and reference for environment-specific limits. Preserve existing work in a dirty worktree.
- For behavior changes, cover the affected practice/storage regression. For UI library changes, check comparable dialogs and controls at short landscape sizes, all locales, selected/disabled states, and larger text.
- Explicitly distinguish isolated tests, web compilation, rendered visual review, and physical-device audio/ad testing. Do not claim unperformed checks or a fixed native issue from a build result alone.
- Keep final summaries concise: what changed, why, validation, and material remaining limitations. When asked to commit, include the commit identifier and a short meaningful change summary.

## Release policy

Ordinary work does not authorize version bumps, publishing, or store submissions.
On an explicit release request, follow the product-version and user-facing release
note policy in `reference.md`, then the existing release checklist. Honor exact
user-specified versions, preserve published labels, and verify the next store build
number. Keep technical detail in commits/reference docs and curate short release
highlights around user benefits instead of listing every spacing or component edit.

- Follow LionBase's product-impact versioning: major for a substantial product milestone, minor for meaningful new capabilities, patch for fixes/polish. Assess all changes since the last actual release; count user impact, not commits or tasks. Treat version components as integers and reset lower components when advancing a higher one.
- Keep `flutter/pubspec.yaml` as the version/build source. The product version maps to Android `versionName`; the positive integer after `+` maps to `versionCode`. Every new bundle upload needs an unused increasing build number across testing and production tracks. Promoting the exact tested bundle uses that bundle's existing code.
- This is a bundled Flutter Android app. Dart UI/audio/asset changes reach installed users through a new app build and Play rollout. A browser-preview deployment does not update the installed app, unlike LionBase's live-web wrapper.
- During ordinary work, maintain only relevant pending highlights in the existing release checklist. Do not bump versions or present pending notes as published. On an explicit release request, compare against the actual Play release, curate the notes as a whole, and explain the chosen product bump.
- Keep About's displayed version, bundle metadata, and approved release notes consistent. About currently contains a literal version; check/update it during release preparation. Do not edit generated Android `local.properties` as the version source.
- Commit messages should state the concrete result in a short imperative subject. Add a body for material implementation, validation, migration/storage, or release-operation details. Do not force a commit/tag/push for each small task or create a release tag during ordinary feature work. Preserve published versions, tags, and existing Git history.
