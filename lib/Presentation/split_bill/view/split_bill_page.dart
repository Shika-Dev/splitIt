import 'package:flutter/material.dart';
import 'package:split_it/Domain/Models/BillItemModel.dart';

class SplitBillPage extends StatelessWidget {
  final BillItemModel billItemModel;
  const SplitBillPage({super.key, required this.billItemModel});

  @override
  Widget build(BuildContext context) {
    return SplitBillPageView();
  }
}

class SplitBillPageView extends StatelessWidget {
  const SplitBillPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
