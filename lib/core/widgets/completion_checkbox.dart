import 'package:flutter/material.dart';

class CompletionCheckbox extends StatefulWidget {
  const CompletionCheckbox({
    super.key,
    required this.value,
    required this.onComplete,
  });

  final bool value;
  final Future<void> Function()? onComplete;

  @override
  State<CompletionCheckbox> createState() => _CompletionCheckboxState();
}

class _CompletionCheckboxState extends State<CompletionCheckbox> {
  bool _pressed = false;

  Future<void> _handleChanged(bool? value) async {
    if (value != true || widget.onComplete == null) return;
    setState(() => _pressed = true);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (mounted) setState(() => _pressed = false);
    await widget.onComplete!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 1.18 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Checkbox(
        value: widget.value,
        onChanged: widget.value || widget.onComplete == null ? null : _handleChanged,
      ),
    );
  }
}
