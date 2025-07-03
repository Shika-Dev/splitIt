import 'package:flutter/material.dart';
import 'package:split_it/Resources/Theme/theme.dart';

class SplitBillButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const SplitBillButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.primaryColor,
        ),
        onPressed: onPressed,
        child: Text(label, style: CustomTheme.bodyMedium),
      ),
    );
  }
}
