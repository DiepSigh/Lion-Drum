import 'dart:math';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'ui/kit_dialog.dart';
import 'ui/kit_styles.dart';

/// Fit a short Library to its contents; keep Close outside a growing beat list.
class SavedBeatsDialog extends StatelessWidget {
  const SavedBeatsDialog({
    required this.filter,
    required this.beats,
    super.key,
  });

  final Widget filter;
  final List<Widget> beats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    return KitDialog(
      scrollable: false,
      titlePadding: KitStyles.compactDialogTitlePadding,
      title: KitDialogHeading(l10n.savedBeats),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: min(size.height * 0.6, 320)),
        child: SizedBox(
          width: min(size.width * 0.75, 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                filter,
                const SizedBox(height: 4),
                if (beats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.noSavedBeats,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  )
                else
                  ...beats,
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.close,
            style: const TextStyle(color: KitStyles.gold),
          ),
        ),
      ],
    );
  }
}
