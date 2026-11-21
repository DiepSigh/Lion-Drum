import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lion_dance_kit/instrument_surface.dart';
import 'package:lion_dance_kit/l10n/app_localizations.dart';
import 'package:lion_dance_kit/performance_controls.dart';
import 'package:lion_dance_kit/ui/kit_startup_cover.dart';
import 'package:lion_dance_kit/ui/kit_styles.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('instrument button cycles all modes during replay in $locale', (
      tester,
    ) async {
      var mode = 0;
      var playbackToggles = 0;
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                l10n = AppLocalizations.of(context);
                return PerformanceControls(
                  mode: mode,
                  soundName: l10n.drumOriginal,
                  recording: false,
                  replaying: true,
                  hasRecording: true,
                  canUseLibrary: true,
                  status: l10n.playing,
                  onMenu: () {},
                  onInstrument: (next) => setState(() => mode = next),
                  onSound: () {},
                  onRecord: () {},
                  onReplay: () => playbackToggles++,
                  onSave: () {},
                  onLibrary: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final names = [l10n.drum, l10n.cymbals, l10n.gong];
      for (final expected in [1, 2, 0]) {
        await tester.tap(find.widgetWithText(TextButton, names[mode]));
        await tester.pumpAndSettle();
        expect(mode, expected);
        expect(
          find.widgetWithText(TextButton, names[expected]),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.widgetWithText(TextButton, l10n.stop), findsOneWidget);
        expect(playbackToggles, 0);
      }
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('startup cover blocks practice until ready in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(432, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final strikes = ValueNotifier(0);
      addTearDown(strikes.dispose);
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);
      var hits = 0;
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: KitStyles.theme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: loading,
                builder: (context, busy, _) => KitStartupCover(
                  loading: busy,
                  child: Builder(
                    builder: (context) {
                      builds++;
                      return InstrumentSurface(
                        color: Colors.brown,
                        primaryLabel: AppLocalizations.of(context).drum,
                        secondaryLabel: AppLocalizations.of(context).side,
                        onPrimaryTap: () => hits++,
                        onSecondaryTap: () => hits++,
                        strikes: strikes,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(builds, greaterThan(0)); // Prepare the main UI under the cover.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(216, 310));
      await tester.tapAt(const Offset(10, 310));
      expect(hits, 0);
      loading.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2999));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tapAt(const Offset(216, 310));
      expect(hits, 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tapAt(const Offset(216, 310));
      await tester.tapAt(const Offset(10, 310));
      expect(hits, 2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'welcome cover keeps waiting when startup exceeds three seconds',
    (tester) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: loading,
              builder: (context, busy, _) => KitStartupCover(
                loading: busy,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      loading.value = false;
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  for (final locale in AppLocalizations.supportedLocales) {
    for (final mode in [1, 2]) {
      for (final state in ['empty', 'ready', 'playing']) {
        final replaying = state == 'playing';
        final hasRecording = state != 'empty';
        testWidgets(
          'practice backing-track controls work in mode $mode, $state, $locale',
          (tester) async {
            var replayToggles = 0;
            var instrumentOpens = 0;
            var libraryOpens = 0;
            late AppLocalizations l10n;
            await tester.pumpWidget(
              MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      l10n = AppLocalizations.of(context);
                      return PerformanceControls(
                        mode: mode,
                        soundName: l10n.drumOriginal,
                        recording: false,
                        replaying: replaying,
                        hasRecording: hasRecording,
                        canUseLibrary: true,
                        status: replaying ? l10n.playing : l10n.ready,
                        onMenu: () {},
                        onInstrument: (_) => instrumentOpens++,
                        onSound: () {},
                        onRecord: () {},
                        onReplay: () => replayToggles++,
                        onSave: () {},
                        onLibrary: () => libraryOpens++,
                      );
                    },
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.text(l10n.record), findsNothing);
            await tester.tap(find.text(mode == 1 ? l10n.cymbals : l10n.gong));
            expect(
              instrumentOpens,
              1,
            ); // Switching stays available during replay.
            final playback = find.widgetWithText(
              TextButton,
              replaying ? l10n.stop : l10n.play,
            );
            if (hasRecording) {
              await tester.tap(playback);
              expect(replayToggles, 1);
            } else {
              expect(tester.widget<TextButton>(playback).onPressed, isNull);
            }
            final library = find.widgetWithText(TextButton, l10n.library);
            expect(library, findsOneWidget);
            if (replaying) {
              // Stop before replacing the backing track from the library.
              expect(tester.widget<TextButton>(library).onPressed, isNull);
            } else {
              await tester.tap(library);
              expect(libraryOpens, 1);
            }
          },
        );
      }
    }
  }

  testWidgets('original hit geometry supports simultaneous thumb strikes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final strikes = ValueNotifier(0);
    addTearDown(strikes.dispose);
    var primary = 0;
    var side = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: InstrumentSurface(
          color: Colors.brown,
          primaryLabel: 'Drum',
          secondaryLabel: 'Side',
          onPrimaryTap: () => primary++,
          onSecondaryTap: () => side++,
          strikes: strikes,
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(const ValueKey('instrument-head')));
    final diameter = min(800 * 0.95, 400 * 2) * 5 / 9;
    expect(rect.width, closeTo(diameter, 0.001));
    expect(rect.center, const Offset(400, 400));

    final left = await tester.startGesture(const Offset(300, 380), pointer: 1);
    final right = await tester.startGesture(const Offset(500, 380), pointer: 2);
    expect(primary, 2); // Sounds fire on down, without waiting for release.
    await left.up();
    await right.up();
    await tester.tapAt(const Offset(20, 380));
    await tester.tapAt(const Offset(780, 380));
    expect(side, 2);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in [
      const Size(432, 320),
      const Size(568, 320),
      const Size(844, 390),
    ]) {
      testWidgets('controls fit $locale at $size and protect the ad slot', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var sideHits = 0;
        var libraryOpens = 0;
        var instrumentOpens = 0;
        late AppLocalizations l10n;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  l10n = AppLocalizations.of(context);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (_) => sideHits++,
                        ),
                      ),
                      PerformanceControls(
                        mode: 0,
                        soundName: l10n.drumOriginal,
                        recording: false,
                        replaying: false,
                        hasRecording: false,
                        canUseLibrary: true,
                        status: l10n.ready,
                        onMenu: () {},
                        onInstrument: (_) => instrumentOpens++,
                        onSound: () {},
                        onRecord: () {},
                        onReplay: () {},
                        onSave: () {},
                        onLibrary: () => libraryOpens++,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final slot = tester.getRect(find.byKey(const ValueKey('banner-slot')));
        expect(slot.size, const Size(320, 50));
        for (final element in find.byType(TextButton).evaluate()) {
          final rect = tester.getRect(find.byWidget(element.widget));
          expect(rect.overlaps(slot), isFalse);
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThan(size.height - 60));
        }
        await tester.tap(find.text(l10n.library));
        expect(libraryOpens, 1); // Available before the first recording.
        await tester.tap(find.text(l10n.drum));
        expect(instrumentOpens, 1);
        expect(sideHits, 0);
        await tester.tapAt(slot.center);
        expect(sideHits, 0); // Empty ad slots must not play percussion.
        await tester.tapAt(Offset(20, size.height - 20));
        expect(sideHits, 1); // Bottom thumb zones stay playable.
      });
    }
  }

  testWidgets('recording retains controls and locks incompatible actions', (
    tester,
  ) async {
    var stops = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PerformanceControls(
            mode: 0,
            soundName: 'Original',
            recording: true,
            replaying: false,
            hasRecording: true,
            canUseLibrary: true,
            status: 'Recording',
            onMenu: () {},
            onInstrument: (_) {},
            onSound: () {},
            onRecord: () => stops++,
            onReplay: () {},
            onSave: () {},
            onLibrary: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Drum', 'Original', 'Play', 'Save', 'Library']) {
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, label),
      );
      expect(button.onPressed, isNull);
    }
    await tester.tap(find.text('Stop'));
    expect(stops, 1);
  });
}
