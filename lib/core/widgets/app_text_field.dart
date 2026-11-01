import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Design system v2 input — `filled` `surface`, hint `ink-muted`, border radius
/// `md` (14) warna `border`, focused → `primary`. Isi teks memakai typography
/// body (PJS 15, `ink`).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.hintStyle,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  /// Ikon di kiri isian (mis. kaca pembesar kotak pencarian). `null` =
  /// tidak ada ikon, sama seperti sebelum parameter ini ada.
  final Widget? prefixIcon;

  final Widget? suffixIcon;

  /// Gaya teks hint. `null` = bawaan design system (`bodyMedium` + `inkMuted`).
  /// Berguna saat pemanggil perlu ukuran lain tanpa menyalin seluruh dekorasi.
  final TextStyle? hintStyle;

  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    const radius = BorderRadius.all(Radius.circular(14)); // rounded.md

    final enabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.border),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.danger),
    );

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      style: theme.textTheme.bodyLarge,
      cursorColor: colors.primary,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
        hintText: hintText,
        labelText: labelText,
        hintStyle: hintStyle ??
            theme.textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
        labelStyle: theme.textTheme.labelLarge?.copyWith(color: colors.inkMuted),
        floatingLabelStyle:
            theme.textTheme.labelLarge?.copyWith(color: colors.primary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: enabledBorder,
        border: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: enabledBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
    );
  }
}