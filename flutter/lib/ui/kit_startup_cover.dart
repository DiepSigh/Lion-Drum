import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'kit_styles.dart';

/// Paint the practice screen underneath, but keep it inert until startup ends.
class KitStartupCover extends StatefulWidget {
  const KitStartupCover({
    required this.loading,
    required this.child,
    super.key,
  });

  final bool loading;
  final Widget child;

  @override
  State<KitStartupCover> createState() => _KitStartupCoverState();
}

class _KitStartupCoverState extends State<KitStartupCover> {
  Timer? _welcomeTimer;
  bool _welcomeElapsed = false;

  @override
  void initState() {
    super.initState();
    // Count from the first visible frame, alongside startup rather than after it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _welcomeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _welcomeElapsed = true);
      });
    });
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.loading || !_welcomeElapsed;
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: loading,
          child: ExcludeSemantics(
            excluding: loading,
            child: IgnorePointer(ignoring: loading, child: widget.child),
          ),
        ),
        if (loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: KitStyles.dialogSurface,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: KitStyles.dialogInsetPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: KitStyles.gold),
                          ),
                          const SizedBox(height: 20),
                          CircularProgressIndicator(
                            color: KitStyles.gold,
                            semanticsLabel: l10n.startupLoading,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.startupLoading,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: KitStyles.statusForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
