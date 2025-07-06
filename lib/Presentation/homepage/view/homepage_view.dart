import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Presentation/scan_page/view/scan_page_view.dart';
import 'package:split_it/Presentation/summary_page/view/summary_page_view.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/card.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<HomepageBloc>()..add(HomepageInit()),
      child: HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.safeBlockHorizontal * 20,
                    ),
                  ),
                  VerticalSeparator(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/ic_coin.png',
                        fit: BoxFit.fitWidth,
                        width: SizeConfig.safeBlockHorizontal * 20,
                      ),
                    ],
                  ),
                  getScanCard(context),
                  VerticalSeparator(),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Flexible(child: getScanManuallyCard()),
                        HorizontalSeparator(width: 1),
                        Flexible(child: getScanByVoiceCard()),
                      ],
                    ),
                  ),
                  VerticalSeparator(height: 3),
                  Text('Histories', style: CustomTheme.bodyMedium),
                  VerticalSeparator(height: 1),
                  Expanded(
                    child: BlocBuilder<HomepageBloc, HomepageState>(
                      builder: (context, state) {
                        if (state.status == HomepageStatus.loading) {
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
                              ],
                            ),
                          );
                        }
                        if (state.status == HomepageStatus.failed) {
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
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          itemBuilder: (_, index) {
                            final summary = state.summaries[index];
                            return Dismissible(
                              key: ValueKey(summary.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                context.read<HomepageBloc>().add(
                                  DeleteSummary(id: summary.id),
                                );

                                return true;
                              },
                              child: getHistoryListItem(context, state, index),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              VerticalSeparator(height: 2),
                          itemCount: state.summaries.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  CustomCard getHistoryListItem(
    BuildContext context,
    HomepageState state,
    int index,
  ) {
    return CustomCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryPage(id: state.summaries[index].id),
        ),
      ),
      children: [
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.summaries[index].billName,
                style: CustomTheme.bodyMedium,
              ),
              Text(
                'You and ${state.summaries[index].userList.length - 1} others',
                style: CustomTheme.captionLarge.copyWith(
                  color: CustomTheme.textColor.withValues(alpha: .67),
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Image.asset(
          'assets/images/ic_arrow.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 5,
        ),
      ],
    );
  }

  CustomCard getScanByVoiceCard() {
    return CustomCard(
      children: [
        Image.asset(
          'assets/images/ic_mic.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 5,
        ),
        HorizontalSeparator(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Split by Voice',
                style: CustomTheme.bodySmall.copyWith(
                  color: CustomTheme.textColor,
                ),
              ),
              Text(
                'Split it using your voice',
                style: CustomTheme.captionLarge.copyWith(
                  color: CustomTheme.textColor.withValues(alpha: 0.5),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }

  CustomCard getScanManuallyCard() {
    return CustomCard(
      children: [
        Image.asset(
          'assets/images/ic_ball.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 5,
        ),
        HorizontalSeparator(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Split Manually',
              style: CustomTheme.bodySmall.copyWith(
                color: CustomTheme.textColor,
              ),
            ),
            Text(
              'Without OCR',
              style: CustomTheme.captionLarge.copyWith(
                color: CustomTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Image background() {
    return Image.asset(
      'assets/background/bg.png',
      fit: BoxFit.cover,
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
    );
  }

  CustomCard getScanCard(BuildContext context) {
    return CustomCard(
      withBorder: true,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: CustomTheme.backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => getScanSheet(context),
        );
      },
      children: [
        Image.asset(
          'assets/images/ic_bill.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 10,
        ),
        HorizontalSeparator(width: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan your bill',
              style: CustomTheme.bodyMedium.copyWith(
                color: CustomTheme.textColor,
              ),
            ),
            Text(
              'and split it fast ⚡',
              style: CustomTheme.bodySmall.copyWith(
                color: CustomTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        Spacer(),
        Image.asset(
          'assets/images/ic_arrow.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 5,
        ),
      ],
    );
  }

  Widget getScanSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomCard(
            onTap: () async {
              XFile? image = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              if (image != null) {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanPage(image: File(image.path)),
                  ),
                );
              }
            },
            children: [
              Text(
                "📷",
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 7),
              ),
              HorizontalSeparator(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Use your Camera",
                    style: CustomTheme.bodySmall.copyWith(
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Text(
                    "Scan bill/receipt using your camera",
                    style: CustomTheme.captionLarge.copyWith(
                      color: CustomTheme.textColor.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Image.asset(
                "assets/images/ic_arrow.png",
                fit: BoxFit.fitWidth,
                width: SizeConfig.safeBlockHorizontal * 5,
              ),
            ],
          ),
          VerticalSeparator(height: 2),
          CustomCard(
            onTap: () async {
              XFile? image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanPage(image: File(image.path)),
                  ),
                );
              }
            },
            children: [
              Text(
                "🖼️",
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 7),
              ),
              HorizontalSeparator(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pick from Gallery",
                    style: CustomTheme.bodySmall.copyWith(
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Text(
                    "Scan bill/receipt from your gallery",
                    style: CustomTheme.captionLarge.copyWith(
                      color: CustomTheme.textColor.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Image.asset(
                "assets/images/ic_arrow.png",
                fit: BoxFit.fitWidth,
                width: SizeConfig.safeBlockHorizontal * 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
