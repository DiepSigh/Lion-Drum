import 'package:flutter/material.dart';

import 'kit_styles.dart';

/// Shared actions retain native focus, tooltips, and disabled semantics.
class KitDialogButton extends StatelessWidget {
  const KitDialogButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: KitStyles.dialogButton(enabled: onPressed != null),
    child: Text(label),
  );
}

/// Compact toolbar action with a full accessible label and tooltip.
class KitToolbarButton extends StatelessWidget {
  const KitToolbarButton({
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.icon,
    this.record = false,
    this.active = false,
    super.key,
  });

  final String label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool record;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? label,
      child: TextButton(
        onPressed: onPressed,
        style: KitStyles.toolbarButton(record: record, active: active),
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
