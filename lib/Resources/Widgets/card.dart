import 'package:flutter/material.dart';
import 'package:split_it/Resources/Theme/theme.dart';

class CustomCard extends StatelessWidget {
  final bool withBorder;
  final List<Widget> children;
  final VoidCallback? onTap;
  const CustomCard({
    super.key,
    this.withBorder = false,
    required this.children,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.primaryColor.withValues(alpha: 0.67),
          borderRadius: BorderRadius.circular(4),
          border: withBorder
              ? Border.all(
                  color: CustomTheme.strokeColor.withValues(alpha: 0.42),
                  width: 1,
                )
              : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
