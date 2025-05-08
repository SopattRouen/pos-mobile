import 'package:flutter/material.dart';

// A reusable helper function for showing a custom bottom sheet
void showCustomBottomSheet({
  required BuildContext context, // Required to show the bottom sheet
  required Widget Function(BuildContext) builder, // Custom content builder for the sheet
  bool isScrollControlled = false, // Whether the bottom sheet can scroll to full height
  bool useRootNavigator = false,
  Color? backgroundColor,
  ShapeBorder? shape,
  Color? barrierColor,
  bool enableDrag = true,
  double? elevation,
  bool isDismissible = true,
  bool? showDragHandle, // For newer Flutter versions (if applicable)
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: backgroundColor,
    shape: shape,
    barrierColor: barrierColor,
    enableDrag: enableDrag,
    elevation: elevation,
    isDismissible: isDismissible,
    // Optional drag handle if supported in Flutter version
    // showDragHandle: showDragHandle,
    builder: builder,
  );
}
