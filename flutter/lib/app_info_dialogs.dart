import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'ui/kit_button.dart';
import 'ui/kit_dialog.dart';
import 'ui/kit_styles.dart';

/// App information presentation; callers own navigation and external launches.
class AppMenuDialog extends StatelessWidget {
  const AppMenuDialog({
    required this.onAbout,
    required this.onLanguage,
    super.key,
  });

  final VoidCallback onAbout;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KitDialog(
      title: KitDialogHeading(l10n.menu),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: KitDialogButton(label: l10n.about, onPressed: onAbout),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: KitDialogButton(label: l10n.language, onPressed: onLanguage),
          ),
        ],
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

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({
    required this.version,
    required this.onVisitWebsite,
    super.key,
  });

  final String version;
  final VoidCallback onVisitWebsite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KitDialog(
      title: KitDialogHeading(l10n.appTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ymt-logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                semanticLabel: 'YMT Lion Dance',
              ),
              const SizedBox(width: 12),
              Text(version, style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aboutDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: KitDialogButton(
              label: l10n.visitYmtWebsite,
              onPressed: onVisitWebsite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.copyright,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
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
