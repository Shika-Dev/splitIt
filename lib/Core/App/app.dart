import 'package:flutter/material.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class SplitBillApp extends StatelessWidget {
  const SplitBillApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(title: 'SplitIt', home: const HomePage());
  }
}
