import 'dart:math';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'ui/kit_button.dart';
import 'ui/kit_styles.dart';

/// Upper controls leave the bottom thumb zones and the banner slot untouched.
class PerformanceControls extends StatelessWidget {
  const PerformanceControls({
    required this.mode,
    required this.soundName,
    required this.recording,
    required this.replaying,
    required this.hasRecording,
    required this.canUseLibrary,
    required this.status,
    required this.onMenu,
    required this.onInstrument,
    required this.onSound,
    required this.onRecord,
    required this.onReplay,
    required this.onSave,
    required this.onLibrary,
    this.banner,
    super.key,
  });

  final int mode;
  final String soundName;
  final bool recording;
  final bool replaying;
  final bool hasRecording;
  final bool canUseLibrary;
  final String status;
  final VoidCallback onMenu;
  final ValueChanged<int> onInstrument;
  final VoidCallback onSound;
  final VoidCallback onRecord;
  final VoidCallback onReplay;
  final VoidCallback onSave;
  final VoidCallback onLibrary;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final idle = !recording && !replaying;
    final modeName = [l10n.drum, l10n.cymbals, l10n.gong][mode];
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Standard banners are 320 x 50. Never put controls over that slot,
          // even before an ad arrives or when an ad fails to load.
          final slotWidth = min(320.0, constraints.maxWidth);
          final narrow = constraints.maxWidth < 464;
          final railWidth = min(
            128.0,
            max(
              60.0,
              narrow
                  ? (constraints.maxWidth - 160) / 2
                  : (constraints.maxWidth - slotWidth) / 2 - 20,
            ),
          );
          final controlsTop = narrow ? 64.0 : 12.0;
          return Stack(
            children: [
              Positioned(
                top: 8,
                left: (constraints.maxWidth - slotWidth) / 2,
                width: slotWidth,
                height: 50,
                child: AbsorbPointer(
                  absorbing: banner == null,
                  child: SizedBox.expand(
                    key: const ValueKey('banner-slot'),
                    child: banner,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: controlsTop,
                width: railWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    KitToolbarButton(label: l10n.menu, onPressed: onMenu),
                    KitToolbarButton(
                      label: modeName,
                      tooltip: l10n.switchInstrument,
                      icon: Icons.sync,
                      onPressed: recording
                          ? null
                          : () => onInstrument((mode + 1) % 3),
                    ),
                    if (mode == 0)
                      KitToolbarButton(
                        label: soundName,
                        tooltip: l10n.drumSound,
                        icon: Icons.keyboard_arrow_down,
                        onPressed: idle ? onSound : null,
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 76,
                left: railWidth + 28,
                right: railWidth + 28,
                child: IgnorePointer(
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: KitStyles.statusForeground,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: controlsTop,
                width: railWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    if (mode == 0)
                      KitToolbarButton(
                        label: recording ? l10n.stop : l10n.record,
                        tooltip: recording ? l10n.stopRecording : l10n.record,
                        onPressed: replaying ? null : onRecord,
                        record: true,
                        active: recording,
                      ),
                    KitToolbarButton(
                      label: replaying ? l10n.stop : l10n.play,
                      tooltip: replaying ? l10n.stopPlayback : l10n.play,
                      onPressed: hasRecording && !recording ? onReplay : null,
                      active: replaying,
                    ),
                    if (mode == 0)
                      KitToolbarButton(
                        label: l10n.save,
                        onPressed: hasRecording && idle && canUseLibrary
                            ? onSave
                            : null,
                      ),
                    KitToolbarButton(
                      label: l10n.library,
                      onPressed: idle && canUseLibrary ? onLibrary : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
