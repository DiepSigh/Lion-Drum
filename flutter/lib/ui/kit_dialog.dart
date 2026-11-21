import 'package:flutter/material.dart';

import 'kit_styles.dart';

/// Every app dialog uses the same centered heading typography.
class KitDialogHeading extends StatelessWidget {
  const KitDialogHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, textAlign: TextAlign.center, style: KitStyles.dialogHeading);
}

/// Compact landscape dialog shell; Flutter owns focus, keyboard and dismissal.
/// Use an internal scrolling body with [scrollable] false for a growing Library.
class KitDialog extends StatelessWidget {
  const KitDialog({
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    this.titlePadding = KitStyles.dialogTitlePadding,
    super.key,
  });

  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsets titlePadding;

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: scrollable,
    insetPadding: KitStyles.dialogInsetPadding,
    titlePadding: titlePadding,
    contentPadding: KitStyles.dialogContentPadding,
    actionsPadding: KitStyles.dialogActionsPadding,
    backgroundColor: KitStyles.dialogSurface,
    shape: KitStyles.dialogShape,
    title: title,
    content: content,
    actions: actions,
  );
}
