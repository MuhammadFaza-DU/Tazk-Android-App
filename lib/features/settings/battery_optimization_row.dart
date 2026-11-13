import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_row.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/battery_optimization_provider.dart';

/// Baris Pengaturan untuk pengecualian optimasi baterai.
///
/// Dulu pengecualian hanya ditawarkan sekali saat app pertama dibuka, jadi user
/// yang menolaknya tidak punya jalan untuk menyalakannya lagi. Baris ini
/// membuat keputusan itu bisa diubah kapan saja.
///
/// Android tidak mengizinkan app melepas pengecualiannya sendiri: sakelar ON
/// membuka dialog izin sistem, sakelar OFF membuka daftar pengaturan baterai.
/// Nilainya selalu dibaca ulang dari platform, tidak pernah ditebak.
class BatteryOptimizationRow extends ConsumerStatefulWidget {
  const BatteryOptimizationRow({super.key, this.showDivider = true});

  final bool showDivider;

  @override
  ConsumerState<BatteryOptimizationRow> createState() =>
      _BatteryOptimizationRowState();
}

class _BatteryOptimizationRowState extends ConsumerState<BatteryOptimizationRow>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(batteryExemptionProvider.notifier).check();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The exemption only changes in the system UI, so re-read it on the way back.
    if (state == AppLifecycleState.resumed) {
      ref.read(batteryExemptionProvider.notifier).check();
    }
  }

  Future<void> _toggle(bool enabled) async {
    final controller = ref.read(batteryExemptionProvider.notifier);
    if (enabled) {
      await controller.requestExemption();
    } else {
      await controller.openSystemSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final exempt = ref.watch(batteryExemptionProvider).isExempt;

    return ListRow(
      leading: _IconTile(
        Icons.battery_saver_rounded,
        tint: exempt ? null : colors.danger,
      ),
      title: l10n.batterySettingsTitle,
      subtitle: exempt ? l10n.batterySettingsOn : l10n.batterySettingsOff,
      showDivider: widget.showDivider,
      trailing: Switch(
        value: exempt,
        activeTrackColor: colors.primary,
        activeThumbColor: colors.onPrimary,
        onChanged: _toggle,
      ),
      onTap: () => _toggle(!exempt),
    );
  }
}

/// Petak ikon 30×30 `primary-container` radius 8 — geometri baris Pengaturan.
class _IconTile extends StatelessWidget {
  const _IconTile(this.icon, {this.tint});

  final IconData icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: tint ?? colors.primary),
    );
  }
}
