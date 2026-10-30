import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// "Shine sweep" sekali jalan: pita gradien melintas dari kiri ke kanan di
/// atas `child`, lalu berhenti. Dipakai untuk momen reward langka (badge /
/// kosmetik yang baru unlock), bukan untuk interaksi frekuensi tinggi.
///
/// Kenapa begini:
/// * Sekali jalan lewat `forward()` — bukan `repeat()`. Efek dekoratif yang
///   berulang tanpa henti akan jadi noise + ticker yang tidak pernah tidur.
/// * Pita digerakkan `Transform.translate` (composite-only). `width`/`left`
///   akan memicu layout tiap frame; `blur` memicu paint mahal.
/// * Curve `Curves.linear`: shine adalah gerak konstan, bukan masuk/keluar —
///   `easeIn` justru menunda momen yang sedang ditonton user.
/// * Reduced motion: ticker tidak pernah jalan dan overlay tidak dirender
///   sama sekali (child dikembalikan apa adanya).
class ShineSweep extends StatefulWidget {
  const ShineSweep({
    super.key,
    required this.child,
    this.autoPlay = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.onCompleted,
  });

  final Widget child;

  /// `false` = overlay tetap ada (posisi diam di luar tepi kiri) tanpa ticker.
  final bool autoPlay;

  /// Mengikuti radius permukaan yang dilintasi (default pill 999).
  final BorderRadius borderRadius;

  /// Dipanggil sekali saat sapuan selesai.
  final VoidCallback? onCompleted;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );

  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleStatus);
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onCompleted?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guard: `context.reduceMotion` baru bisa dibaca di sini, dan kita hanya
    // boleh memulai sekali (didChangeDependencies bisa terpanggil ulang).
    if (_started) return;
    _started = true;
    if (!widget.autoPlay || context.reduceMotion) return;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion → tidak ada gerak sama sekali, child apa adanya.
    if (context.reduceMotion) return widget.child;

    final highlight = context.colors.surface.withValues(alpha: 0.55);

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              key: const Key('shine_overlay'),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // t: 0 → pita di luar tepi kiri, 1 → di luar tepi kanan.
                      final x = -w + _controller.value * 2 * w;
                      return Transform.translate(
                        offset: Offset(x, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: w * 0.45,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  highlight,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}