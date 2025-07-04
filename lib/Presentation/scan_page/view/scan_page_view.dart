import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Presentation/split_bill/view/split_bill_page.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/button.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/Widgets/textfield.dart';
import 'package:split_it/Resources/utils/size_config.dart';

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
      body: SafeArea(
        child: BlocConsumer<ScanPageBloc, ScanPageState>(
          listener: (context, state) {
            if (state.status == ScanPageStatus.finish &&
                state.billItem != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SplitBillPage(id: state.id)),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ScanPageStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/loading.json',
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.safeBlockHorizontal * 40,
                    ),
                    VerticalSeparator(height: 2),
                    const AnimatedBillLoadingText(),
                  ],
                ),
              );
            }
            if (state.status == ScanPageStatus.failed) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/failed.json',
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.safeBlockHorizontal * 30,
                    ),
                    VerticalSeparator(height: 3),
                    Text(
                      state.errorMessage ?? '',
                      style: CustomTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 50,
                      child: SplitBillButton(
                        onPressed: () => Navigator.pop(context),
                        label: 'Re-scan your bill',
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(state.billItem?.billName ?? '', style: CustomTheme.h3),
                  VerticalSeparator(height: 3),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              state.isEdit
                                  ? SplitBillTextField(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 50,
                                      controller: state.controllers[index * 3],
                                      hint: 'Product Name',
                                    )
                                  : Text(
                                      state.billItem?.items?[index].name ?? '',
                                      style: CustomTheme.bodySmall,
                                    ),
                              state.isEdit
                                  ? SplitBillTextField(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
                                      controller:
                                          state.controllers[index * 3 + 2],
                                      hint: 'Price',
                                    )
                                  : Text(
                                      state.billItem?.items?[index].price
                                              .toString() ??
                                          '',
                                      style: CustomTheme.bodySmall,
                                    ),
                            ],
                          ),
                          VerticalSeparator(height: 1),
                          state.isEdit
                              ? SplitBillTextField(
                                  width: SizeConfig.safeBlockHorizontal * 20,
                                  controller: state.controllers[index * 3 + 1],
                                  hint: 'Qty',
                                )
                              : Text(
                                  'x ${state.billItem?.items?[index].quantity ?? 0}',
                                  style: CustomTheme.bodySmall,
                                ),
                        ],
                      ),
                      separatorBuilder: (_, __) => VerticalSeparator(height: 1),
                      itemCount: state.billItem?.items?.length ?? 0,
                    ),
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: CustomTheme.bodySmall),
                      state.isEdit
                          ? SplitBillTextField(
                              width: SizeConfig.safeBlockHorizontal * 50,
                              controller:
                                  state.controllers[(state
                                              .billItem
                                              ?.items
                                              ?.length ??
                                          0) *
                                      3],
                              hint: 'Subtotal',
                            )
                          : Text(
                              state.billItem?.subtotal.toString() ?? '',
                              style: CustomTheme.bodySmall,
                            ),
                    ],
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Charge', style: CustomTheme.bodySmall),
                      state.isEdit
                          ? SplitBillTextField(
                              width: SizeConfig.safeBlockHorizontal * 50,
                              controller:
                                  state.controllers[(state
                                                  .billItem
                                                  ?.items
                                                  ?.length ??
                                              0) *
                                          3 +
                                      1],
                              hint: 'Subtotal',
                            )
                          : Text(
                              state.billItem?.service.toString() ?? '',
                              style: CustomTheme.bodySmall,
                            ),
                    ],
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax', style: CustomTheme.bodySmall),
                      state.isEdit
                          ? SplitBillTextField(
                              width: SizeConfig.safeBlockHorizontal * 50,
                              controller:
                                  state.controllers[(state
                                                  .billItem
                                                  ?.items
                                                  ?.length ??
                                              0) *
                                          3 +
                                      2],
                              hint: 'Subtotal',
                            )
                          : Text(
                              state.billItem?.tax.toString() ?? '',
                              style: CustomTheme.bodySmall,
                            ),
                    ],
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount', style: CustomTheme.bodySmall),
                      state.isEdit
                          ? SplitBillTextField(
                              width: SizeConfig.safeBlockHorizontal * 50,
                              controller:
                                  state.controllers[(state
                                                  .billItem
                                                  ?.items
                                                  ?.length ??
                                              0) *
                                          3 +
                                      3],
                              hint: 'Subtotal',
                            )
                          : Text(
                              state.billItem?.discount.toString() ?? '',
                              style: CustomTheme.bodySmall,
                            ),
                    ],
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: CustomTheme.bodySmall),
                      state.isEdit
                          ? SplitBillTextField(
                              width: SizeConfig.safeBlockHorizontal * 50,
                              controller:
                                  state.controllers[(state
                                                  .billItem
                                                  ?.items
                                                  ?.length ??
                                              0) *
                                          3 +
                                      4],
                              hint: 'Subtotal',
                            )
                          : Text(
                              state.billItem?.total.toString() ?? '',
                              style: CustomTheme.bodySmall,
                            ),
                    ],
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: SplitBillButton(
                          onPressed: () {
                            context.read<ScanPageBloc>().add(EditScanPage());
                          },
                          label: 'Edit',
                        ),
                      ),
                      HorizontalSeparator(width: 3),
                      Flexible(
                        child: SplitBillButton(
                          onPressed: () {
                            context.read<ScanPageBloc>().add(
                              EditScanPageDispose(),
                            );
                          },
                          label: 'Confirm',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedBillLoadingText extends StatefulWidget {
  const AnimatedBillLoadingText({Key? key}) : super(key: key);

  @override
  State<AnimatedBillLoadingText> createState() =>
      _AnimatedBillLoadingTextState();
}

class _AnimatedBillLoadingTextState extends State<AnimatedBillLoadingText> {
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = _dotCount % 3 + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    return Text(
      'Please wait while we analyze \n your bill$dots',
      style: CustomTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}
