import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lion_dance_kit/l10n/app_localizations.dart';
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
                    'menu' => [l10n.about, l10n.language, l10n.visitYmtWebsite],
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
                          builder: (dialogContext) => KitDialog(
                            title: Row(
                              children: [
                                if (surface == 'menu') ...[
                                  Image.asset(
                                    'assets/images/ymt-logo.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(child: Text(title)),
                              ],
                            ),
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
                                                  onPressed: () => selections++,
                                                  icon: Icon(
                                                    row == 0 && col == 0
                                                        ? Icons.check
                                                        : Icons
                                                              .volume_up_outlined,
                                                    size: 18,
                                                  ),
                                                  label: Text(
                                                    choices[row * 2 + col],
                                                  ),
                                                  style: KitStyles.choiceButton(
                                                    selected:
                                                        row == 0 && col == 0,
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
                                      if (index != 0) const SizedBox(height: 8),
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
