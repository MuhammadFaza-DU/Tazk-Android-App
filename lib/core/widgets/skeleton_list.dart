import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'app_card.dart';

/// State memuat — board `11 States` (LOADING): skeleton, BUKAN spinner.
///
/// `rows` kartu placeholder (`AppCard`) berisi kotak 40×40 `surface-alt`
/// (radius `sm`) + dua bar pill (lebar 60% & 35%). Redup halus bolak-balik
/// lewat SATU `AnimationController` + `FadeTransition` (composite-only, tanpa
/// gradient bergerak/shadow). Saat reduced-motion aktif skeleton tampil statis
/// dan tidak ada ticker yang berjalan.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.rows = 3});

  final int rows;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );

  late final Animation<double> _pulse = Tween<double>(begin: 1, end: 0.45)
      .animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.easeGentle),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = context.reduceMotion;

    return FadeTransition(
      opacity: reduced ? const AlwaysStoppedAnimation<double>(1) : _pulse,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.rows; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: const _SkeletonCard(),
            ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(8), // rounded.sm
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBar(height: 12, widthFactor: 0.6),
                SizedBox(height: 8),
                _SkeletonBar(height: 10, widthFactor: 0.35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.height, required this.widthFactor});

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(999), // rounded.pill
        ),
      ),
    );
  }
}