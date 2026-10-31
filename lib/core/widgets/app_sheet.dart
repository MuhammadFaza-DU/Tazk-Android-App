import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Bottom sheet bertema: bg `surface`, radius atas `xl` (24), grab handle 40Ã—4
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
    // Entrance/exit memakai token motion: `base` (220ms) + ease-standard.
    // `context.motion` otomatis menjadikan durasi nol saat reduced-motion.
    sheetAnimationStyle: AnimationStyle(
      duration: context.motion(AppMotion.base),
      curve: AppMotion.easeStandard,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // rounded.xl
    ),
    builder: (sheetContext) {
      // Keyboard-aware: tanpa ini, sheet dengan field teks (mis. atur durasi
      // Pomodoro) tertutup keyboard dan tombol aksinya tak bisa dijangkau.
      // Inset bernilai 0 saat keyboard tertutup, jadi sheet lain tak berubah.
      final keyboardInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: AppSheetHandle(),
            ),
            const SizedBox(height: 12),
            Flexible(child: child),
          ],
        ),
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
