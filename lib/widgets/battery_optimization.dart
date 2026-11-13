import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

const _channel = MethodChannel('com.tazk.tazk/app_settings');

/// Battery-optimisation state of this app.
///
/// Android (and Samsung's sleeping-app policy in particular) defers background
/// work for an app that has been idle. The widget tap path no longer depends on
/// job scheduling, but reminders still do, so the app asks once for an
/// exemption instead of silently letting alarms drift.
class BatteryOptimization {
  const BatteryOptimization._();

  static Future<bool> isIgnoring() async {
    try {
      return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          true;
    } catch (_) {
      // Unknown platform: treat as fine rather than nagging the user.
      return true;
    }
  }

  static Future<void> request() async {
    try {
      await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } catch (_) {
      // Best effort.
    }
  }

  /// Opens the system list where the user can switch this app's exemption off.
  /// Android offers no API to revoke it from inside the app.
  static Future<void> openSystemSettings() async {
    try {
      await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
    } catch (_) {
      // Best effort.
    }
  }

  static Future<bool> promptShown() async {
    try {
      return await _channel.invokeMethod<bool>('batteryPromptShown') ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> markPromptShown() async {
    try {
      await _channel.invokeMethod<void>('markBatteryPromptShown');
    } catch (_) {
      // Best effort.
    }
  }
}

/// Asks once, and only when Android is actually restricting this app.
Future<void> maybePromptBatteryOptimization(BuildContext context) async {
  if (await BatteryOptimization.isIgnoring()) return;
  if (await BatteryOptimization.promptShown()) return;
  await BatteryOptimization.markPromptShown();
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  final allow = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.batteryTitle),
      content: Text(l10n.batteryBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.batteryLater),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.batteryAllow),
        ),
      ],
    ),
  );
  if (allow == true) {
    await BatteryOptimization.request();
  }
}
