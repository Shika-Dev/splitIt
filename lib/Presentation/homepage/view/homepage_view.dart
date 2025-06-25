import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/camera.dart';
import 'package:split_it/Resources/Widgets/card.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomepageBloc(),
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
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.fitWidth,
                    width: SizeConfig.safeBlockHorizontal * 20,
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
                  VerticalSeparator(),
                ],
              ),
            ),
          ),
        ],
      ),
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
        showBottomSheet(
          context: context,
          builder: (context) => getScanSheet(context),
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
    return BottomSheet(
      backgroundColor: CustomTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      onClosing: () {},
      builder: (_) => Column(
        children: [
          CustomCard(
            onTap: () async {
              XFile? image = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              if (image != null) {
                InputImage inputImage = InputImage.fromFile(File(image.path));
              }
            },
            children: [
              Text(
                "📷",
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 10),
              ),
              HorizontalSeparator(width: 3),
              Column(
                children: [
                  Text(
                    "Use your Camera",
                    style: CustomTheme.bodyMedium.copyWith(
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Text(
                    "Scan bill/receipt using your camera",
                    style: CustomTheme.bodySmall.copyWith(
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
                InputImage inputImage = InputImage.fromFile(File(image.path));
              }
            },
            children: [
              Text(
                "🖼️",
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 10),
              ),
              HorizontalSeparator(width: 3),
              Column(
                children: [
                  Text(
                    "Pick from Gallery",
                    style: CustomTheme.bodyMedium.copyWith(
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Text(
                    "Scan bill/receipt from your gallery",
                    style: CustomTheme.bodySmall.copyWith(
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
