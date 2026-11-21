import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lion_dance_kit/app_info_dialogs.dart';
import 'package:lion_dance_kit/l10n/app_localizations.dart';
import 'package:lion_dance_kit/saved_beats_dialog.dart';
import 'package:lion_dance_kit/ui/kit_button.dart';
import 'package:lion_dance_kit/ui/kit_dialog.dart';
import 'package:lion_dance_kit/ui/kit_styles.dart';

// Contract fixtures exercise the same shared shell/actions as app dialogs.
// Optional UI_REVIEW_DIR snapshots support visual comparison without baselines.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // An optional SDK font directory makes local review PNGs readable; normal
    // regression runs retain Flutter's deterministic test font.
    const fontDir = String.fromEnvironment('UI_REVIEW_FONT_DIR');
    if (fontDir.isEmpty) return;
    for (final entry in {
      'Roboto': '$fontDir/Roboto/Roboto-Regular.ttf',
      'MaterialIcons': '$fontDir/MaterialIcons-Regular.otf',
    }.entries) {
      final bytes = await File(entry.value).readAsBytes();
      final loader = FontLoader(entry.key)
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await loader.load();
    }
  });
  for (final locale in AppLocalizations.supportedLocales) {
    for (final count in [0, 1, 20]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('Library fits $count beats in $locale at scale $scale', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(568, 320);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          late AppLocalizations l10n;
          await tester.pumpWidget(
            RepaintBoundary(
              key: const ValueKey('library-capture'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: KitStyles.theme,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Builder(
                  builder: (context) {
                    l10n = AppLocalizations.of(context);
                    return Scaffold(
                      body: TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => SavedBeatsDialog(
                            filter: SizedBox(
                              height: 48,
                              child: Center(child: Text(l10n.filterBy)),
                            ),
                            beats: [
                              for (var index = 0; index < count; index++)
                                SizedBox(
                                  height: 64,
                                  child: Center(child: Text('Beat $index')),
                                ),
                            ],
                          ),
                        ),
                        child: const Text('Open'),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final heading = tester.widget<Text>(
            find.descendant(
              of: find.byType(KitDialogHeading),
              matching: find.byType(Text),
            ),
          );
          expect(
            heading.style?.fontSize,
            16,
          ); // Same heading size across dialogs.
          expect(find.text(l10n.saveCurrent), findsNothing);
          final dialog = tester.getRect(
            find
                .descendant(
                  of: find.byType(AlertDialog),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(dialog.top, greaterThanOrEqualTo(0));
          expect(dialog.bottom, lessThanOrEqualTo(320));
          if (count == 0 && scale == 1) {
            expect(dialog.height, lessThan(250));
          }
          final scroll = tester.state<ScrollableState>(
            find.descendant(
              of: find.byType(SavedBeatsDialog),
              matching: find.byType(Scrollable),
            ),
          );
          if (count == 20) {
            expect(scroll.position.maxScrollExtent, greaterThan(0));
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -1600),
            );
            await tester.pumpAndSettle();
            expect(find.text('Beat 19').hitTestable(), findsOneWidget);
          }
          final close = find.widgetWithText(TextButton, l10n.close);
          expect(close.hitTestable(), findsOneWidget);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(find.byType(SavedBeatsDialog), findsNothing);
        });
      }
    }

    for (final scale in [1.0, 1.5]) {
      testWidgets('About owns YMT branding in $locale at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(568, 320);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var visits = 0;
        late AppLocalizations l10n;
        await tester.pumpWidget(
          RepaintBoundary(
            key: const ValueKey('about-capture'),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: KitStyles.theme,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Builder(
                builder: (context) {
                  l10n = AppLocalizations.of(context);
                  return Scaffold(
                    body: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AppAboutDialog(
                          version: 'v1.1.2',
                          onVisitWebsite: () => visits++,
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          for (final asset in [
            'assets/images/ymt-logo.png',
            'assets/images/LionIcon.png',
          ]) {
            await precacheImage(
              AssetImage(asset),
              tester.element(find.byType(Scaffold)),
            );
          }
        });
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final heading = tester.widget<Text>(
          find.descendant(
            of: find.byType(KitDialogHeading),
            matching: find.byType(Text),
          ),
        );
        expect(
          heading.style?.fontSize,
          16,
        ); // Same heading size across dialogs.
        expect(find.bySemanticsLabel('YMT Lion Dance'), findsOneWidget);
        final visit = find.widgetWithText(TextButton, l10n.visitYmtWebsite);
        await tester.ensureVisible(visit);
        await tester.tap(visit);
        expect(visits, 1);
        expect(find.byType(AppAboutDialog), findsOneWidget);
        const reviewDir = String.fromEnvironment('UI_REVIEW_DIR');
        if (reviewDir.isNotEmpty) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('about-capture')),
            );
            final rendered = await boundary.toImage();
            final bytes = await rendered.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final output = File(
              '$reviewDir/about-${locale.languageCode}-$scale.png',
            );
            await output.parent.create(recursive: true);
            await output.writeAsBytes(bytes!.buffer.asUint8List());
            rendered.dispose();
          });
        }
        final close = find.widgetWithText(TextButton, l10n.close);
        expect(tester.getRect(close).bottom, lessThanOrEqualTo(320));
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(find.byType(AppAboutDialog), findsNothing);
      });
    }

    for (final surface in ['menu', 'language', 'sound']) {
      testWidgets('$surface fits short landscape in $locale', (tester) async {
        tester.view.physicalSize = const Size(568, 320);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const captureKey = ValueKey('capture');
        late List<String> choices;
        var selections = 0;
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: KitStyles.theme,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  choices = switch (surface) {
                    'menu' => [l10n.about, l10n.language],
                    'language' => [
                      l10n.languageEnglish,
                      l10n.languageChinese,
                      l10n.languageVietnamese,
                    ],
                    _ => [
                      l10n.drumOriginal,
                      l10n.drumDeep,
                      l10n.drumWarm,
                      l10n.drumTight,
                    ],
                  };
                  final title = switch (surface) {
                    'menu' => l10n.menu,
                    'language' => l10n.language,
                    _ => l10n.drumSound,
                  };
                  return Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => surface == 'menu'
                              ? AppMenuDialog(
                                  onAbout: () => selections++,
                                  onLanguage: () => selections++,
                                )
                              : KitDialog(
                                  title: KitDialogHeading(title),
                                  content: SizedBox(
                                    width: surface == 'sound' ? 360 : 280,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (surface == 'sound') ...[
                                          Text(l10n.drumSoundHint),
                                          const SizedBox(height: 8),
                                          for (var row = 0; row < 2; row++)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: row == 0 ? 8 : 0,
                                              ),
                                              child: Row(
                                                children: [
                                                  for (
                                                    var col = 0;
                                                    col < 2;
                                                    col++
                                                  ) ...[
                                                    if (col == 1)
                                                      const SizedBox(width: 8),
                                                    Expanded(
                                                      child: TextButton.icon(
                                                        onPressed: () =>
                                                            selections++,
                                                        icon: Icon(
                                                          row == 0 && col == 0
                                                              ? Icons.check
                                                              : Icons
                                                                    .volume_up_outlined,
                                                          size: 18,
                                                        ),
                                                        label: Text(
                                                          choices[row * 2 +
                                                              col],
                                                        ),
                                                        style:
                                                            KitStyles.choiceButton(
                                                              selected:
                                                                  row == 0 &&
                                                                  col == 0,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                        ] else
                                          for (
                                            var index = 0;
                                            index < choices.length;
                                            index++
                                          ) ...[
                                            if (index != 0)
                                              const SizedBox(height: 8),
                                            SizedBox(
                                              width: double.infinity,
                                              child: KitDialogButton(
                                                label: choices[index],
                                                onPressed: () => selections++,
                                              ),
                                            ),
                                          ],
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(),
                                      child: Text(l10n.close),
                                    ),
                                  ],
                                ),
                        ),
                        child: const Text('Open'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/images/ymt-logo.png'),
            tester.element(find.byType(Scaffold)),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final heading = tester.widget<Text>(
          find.descendant(
            of: find.byType(KitDialogHeading),
            matching: find.byType(Text),
          ),
        );
        expect(
          heading.style?.fontSize,
          16,
        ); // Same heading size across dialogs.
        if (surface == 'menu') {
          expect(find.byType(Image), findsNothing);
          expect(
            find.text(
              AppLocalizations.of(
                tester.element(find.byType(AppMenuDialog)),
              ).visitYmtWebsite,
            ),
            findsNothing,
          );
        }
        for (final state in tester.stateList<ScrollableState>(
          find.descendant(
            of: find.byType(KitDialog),
            matching: find.byType(Scrollable),
          ),
        )) {
          expect(state.position.maxScrollExtent, lessThanOrEqualTo(0.5));
        }
        for (final choice in choices) {
          final rect = tester.getRect(find.text(choice));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(320));
        }
        await tester.tap(find.text(choices.last));
        expect(selections, 1);
        await tester.pumpAndSettle();

        const reviewDir = String.fromEnvironment('UI_REVIEW_DIR');
        if (reviewDir.isNotEmpty) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(captureKey),
            );
            final rendered = await boundary.toImage();
            final bytes = await rendered.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final output = File(
              '$reviewDir/$surface-${locale.languageCode}.png',
            );
            await output.parent.create(recursive: true);
            await output.writeAsBytes(bytes!.buffer.asUint8List());
            rendered.dispose();
          });
        }
        final close = find.widgetWithText(
          TextButton,
          AppLocalizations.of(tester.element(find.byType(KitDialog))).close,
        );
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(find.byType(KitDialog), findsNothing);
      });
    }
  }
}
