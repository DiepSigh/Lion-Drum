import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ui/kit_styles.dart';

/// The original bottom-centered instrument, including its full-screen side zone.
class InstrumentSurface extends StatefulWidget {
  const InstrumentSurface({
    required this.color,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    required this.strikes,
    super.key,
  });

  final Color color;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;
  // Positive values flash the instrument; negative values flash the side zone.
  final ValueListenable<int> strikes;

  @override
  State<InstrumentSurface> createState() => _InstrumentSurfaceState();
}

class _InstrumentSurfaceState extends State<InstrumentSurface> {
  Timer? _primaryTimer;
  Timer? _secondaryTimer;
  bool _primaryFlash = false;
  bool _secondaryFlash = false;

  @override
  void initState() {
    super.initState();
    widget.strikes.addListener(_onStrike);
  }

  @override
  void didUpdateWidget(InstrumentSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strikes != oldWidget.strikes) {
      oldWidget.strikes.removeListener(_onStrike);
      widget.strikes.addListener(_onStrike);
    }
  }

  void _onStrike() {
    if (widget.strikes.value > 0) {
      _primaryTimer?.cancel();
      setState(() => _primaryFlash = true);
      _primaryTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _primaryFlash = false);
      });
    } else {
      _secondaryTimer?.cancel();
      setState(() => _secondaryFlash = true);
      _secondaryTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _secondaryFlash = false);
      });
    }
  }

  @override
  void dispose() {
    widget.strikes.removeListener(_onStrike);
    _primaryTimer?.cancel();
    _secondaryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Keep these dimensions and the hit test identical to the original UI.
        final diameter = min(w * 0.95, h * 2.0) * 5 / 9;
        final radius = diameter / 2;
        final center = Offset(w / 2, h);
        const gold = KitStyles.gold;
        const labelStyle = TextStyle(
          color: KitStyles.instrumentLabel,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        );

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            if ((event.localPosition - center).distance <= radius) {
              widget.onPrimaryTap();
            } else {
              widget.onSecondaryTap();
            }
          },
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _secondaryFlash
                          ? const RadialGradient(
                              radius: 1.1,
                              colors: [Color(0x35D3A45B), Colors.transparent],
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: center.dx - radius,
                top: center.dy - radius,
                width: diameter,
                height: diameter,
                child: Semantics(
                  button: true,
                  label: widget.primaryLabel,
                  onTap: widget.onPrimaryTap,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey('instrument-head'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.5),
                          colors: [
                            Color.lerp(
                              widget.color,
                              Colors.white,
                              _primaryFlash ? 0.35 : 0.12,
                            )!,
                            widget.color,
                          ],
                        ),
                        border: Border.all(color: gold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withAlpha(_primaryFlash ? 100 : 20),
                            blurRadius: _primaryFlash ? 32 : 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: min(48, radius * 0.4),
                child: IgnorePointer(
                  child: Text(
                    widget.primaryLabel,
                    textAlign: TextAlign.center,
                    style: labelStyle,
                  ),
                ),
              ),
              for (final left in [true, false])
                Positioned(
                  left: left ? 16 : w / 2 + radius + 8,
                  right: left ? w / 2 + radius + 8 : 16,
                  bottom: 30,
                  child: Semantics(
                    button: true,
                    label: widget.secondaryLabel,
                    onTap: widget.onSecondaryTap,
                    child: IgnorePointer(
                      child: Text(
                        widget.secondaryLabel,
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
