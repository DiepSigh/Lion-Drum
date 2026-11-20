import 'package:flutter/material.dart';

import 'kit_styles.dart';

/// Compact landscape dialog shell; Flutter owns focus, keyboard and dismissal.
/// Use an internal scrolling body with [scrollable] false for a growing Library.
class KitDialog extends StatelessWidget {
  const KitDialog({
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    super.key,
  });

  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: scrollable,
    insetPadding: KitStyles.dialogInsetPadding,
    titlePadding: KitStyles.dialogTitlePadding,
    contentPadding: KitStyles.dialogContentPadding,
    actionsPadding: KitStyles.dialogActionsPadding,
    backgroundColor: KitStyles.dialogSurface,
    shape: KitStyles.dialogShape,
    title: title,
    content: content,
    actions: actions,
  );
}
