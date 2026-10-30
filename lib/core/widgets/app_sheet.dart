import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bottom sheet bertema: bg `surface`, radius atas `xl` (24), grab handle 40×4
/// pill (`border`) ditengahkan pada full width (bukan di dalam padding konten).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // rounded.xl
    ),
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: AppSheetHandle(),
          ),
          const SizedBox(height: 12),
          Flexible(child: child),
        ],
      );
    },
  );
}

/// Grab handle drag (DESIGN `sheet-handle`). Ditengah full-width sheet.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
    );
  }
}