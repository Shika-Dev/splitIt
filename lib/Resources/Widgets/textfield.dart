import 'package:flutter/material.dart';
import 'package:split_it/Resources/Theme/theme.dart';

class SplitBillTextField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final String hint;
  const SplitBillTextField({
    super.key,
    required this.width,
    required this.controller,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        style: CustomTheme.bodySmall,
        decoration: InputDecoration(
          hint: Text(hint),
          filled: true,
          fillColor: CustomTheme.primaryColor,
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
      ),
    );
  }
}
