import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/separator.dart';

class ScanPage extends StatelessWidget {
  final File image;
  const ScanPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<ScanPageBloc>()..add(InitScanPage(image: image)),
      child: ScanPageView(),
    );
  }
}

class ScanPageView extends StatelessWidget {
  const ScanPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: BlocBuilder<ScanPageBloc, ScanPageState>(
        builder: (context, state) {
          if (state.status == ScanPageStatus.loading) {
            return Center(child: Lottie.asset('assets/lottie/loading.json'));
          }
          return ListView.separated(
            itemBuilder: (_, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.billItem?.items?[index].name ?? '',
                  style: CustomTheme.captionMedium,
                ),
                Text(
                  state.billItem?.items?[index].quantity.toString() ?? '',
                  style: CustomTheme.captionMedium,
                ),
                Text(
                  state.billItem?.items?[index].price.toString() ?? '',
                  style: CustomTheme.captionMedium,
                ),
              ],
            ),
            separatorBuilder: (_, __) => VerticalSeparator(height: 1),
            itemCount: state.billItem?.items?.length ?? 0,
          );
        },
      ),
    );
  }
}
