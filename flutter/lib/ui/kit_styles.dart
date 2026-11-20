import 'package:flutter/material.dart';

/// Reviewed visual tokens. Change shared values here rather than per screen.
abstract final class KitStyles {
  static const gold = Color(0xFFD7B675);
  static const controlGold = Color(0xFFE5CA9A);
  static const brandRed = Color(0xFFCC0000);
  static const dialogSurface = Color(0xFF1A0000);
  static const controlSurface = Color(0xE62C151B);
  static const recordingSurface = Color(0xFF942B39);
  static const recordingBorder = Color(0xFFC35158);
  static const recordingForeground = Color(0xFFFFF1DF);
  static const statusForeground = Color(0xFFC8B09C);
  static const instrumentLabel = Color(0xB3E5CCA4);
  static const backgroundColors = [Color(0xFF481C24), Color(0xFF200C12)];

  static const controlHeight = 44.0;
  static const choiceHeight = 48.0;
  static const dialogInsetPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
  static const dialogTitlePadding = EdgeInsets.fromLTRB(20, 12, 20, 8);
  static const dialogContentPadding = EdgeInsets.symmetric(horizontal: 20);
  static const dialogActionsPadding = EdgeInsets.fromLTRB(12, 0, 12, 4);
  static const dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    side: BorderSide(color: gold, width: 2),
  );

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ButtonStyle dialogButton({required bool enabled}) =>
      TextButton.styleFrom(
        foregroundColor: gold,
        disabledForegroundColor: Colors.white38,
        side: BorderSide(color: enabled ? gold : Colors.white24),
      );

  // Library rows intentionally retain their established compact action size.
  static ButtonStyle get smallDialogButton => TextButton.styleFrom(
    foregroundColor: gold,
    disabledForegroundColor: Colors.white38,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    minimumSize: const Size(0, 32),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static ButtonStyle choiceButton({required bool selected}) =>
      TextButton.styleFrom(
        minimumSize: const Size(choiceHeight, choiceHeight),
        foregroundColor: selected ? gold : Colors.white70,
        backgroundColor: selected ? gold.withAlpha(24) : Colors.transparent,
        side: BorderSide(color: selected ? gold : Colors.white24),
      );

  static ButtonStyle toolbarButton({
    required bool record,
    required bool active,
  }) => TextButton.styleFrom(
    minimumSize: const Size(controlHeight, controlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: record ? recordingForeground : controlGold,
    disabledForegroundColor: controlGold.withAlpha(85),
    backgroundColor: record ? recordingSurface : controlSurface,
    side: BorderSide(
      color: (record ? recordingBorder : controlGold).withAlpha(
        active ? 230 : 75,
      ),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
  );
}
