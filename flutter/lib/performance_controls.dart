import 'dart:math';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

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
  final VoidCallback onInstrument;
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
                    _ControlButton(label: l10n.menu, onPressed: onMenu),
                    _ControlButton(
                      label: modeName,
                      tooltip: l10n.switchInstrument,
                      icon: Icons.keyboard_arrow_down,
                      onPressed: idle ? onInstrument : null,
                    ),
                    if (mode == 0)
                      _ControlButton(
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
                      color: Color(0xFFC8B09C),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (mode == 0)
                Positioned(
                  right: 12,
                  top: controlsTop,
                  width: railWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      _ControlButton(
                        label: recording ? l10n.stop : l10n.record,
                        tooltip: recording ? l10n.stopRecording : l10n.record,
                        onPressed: replaying ? null : onRecord,
                        record: true,
                        active: recording,
                      ),
                      _ControlButton(
                        label: replaying ? l10n.stop : l10n.play,
                        tooltip: replaying ? l10n.stopPlayback : l10n.play,
                        onPressed: hasRecording && !recording ? onReplay : null,
                        active: replaying,
                      ),
                      _ControlButton(
                        label: l10n.save,
                        onPressed: hasRecording && idle && canUseLibrary
                            ? onSave
                            : null,
                      ),
                      _ControlButton(
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

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.icon,
    this.record = false,
    this.active = false,
  });

  final String label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool record;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE5CA9A);
    return Tooltip(
      message: tooltip ?? label,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: record ? const Color(0xFFFFF1DF) : gold,
          disabledForegroundColor: gold.withAlpha(85),
          backgroundColor: record
              ? const Color(0xFF942B39)
              : const Color(0xE62C151B),
          side: BorderSide(
            color: (record ? const Color(0xFFC35158) : gold).withAlpha(
              active ? 230 : 75,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record) ...[
              const Icon(Icons.circle, size: 8),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
