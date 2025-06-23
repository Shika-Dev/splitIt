import 'package:flutter/material.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class VerticalSeparator extends StatelessWidget {
  final double height;
  const VerticalSeparator({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: SizeConfig.safeBlockVertical * height);
  }
}

class HorizontalSeparator extends StatelessWidget {
  final double width;
  const HorizontalSeparator({super.key, this.width = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: SizeConfig.safeBlockHorizontal * width);
  }
}
