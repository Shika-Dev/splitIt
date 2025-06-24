import 'package:flutter/material.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/card.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageView();
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
                  getScanCard(),
                  VerticalSeparator(),
                  getScanManuallyCard(),
                  VerticalSeparator(),
                  getScanByVoiceCard(),
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
          width: SizeConfig.safeBlockHorizontal * 7,
        ),
        HorizontalSeparator(width: 1),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split by Voice',
              style: CustomTheme.bodyMedium.copyWith(
                color: CustomTheme.textColor,
              ),
            ),
            Text(
              'Split it using your voice',
              style: CustomTheme.bodySmall.copyWith(
                color: CustomTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
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
          width: SizeConfig.safeBlockHorizontal * 7,
        ),
        HorizontalSeparator(width: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Manually',
              style: CustomTheme.bodyMedium.copyWith(
                color: CustomTheme.textColor,
              ),
            ),
            Text(
              'Without OCR',
              style: CustomTheme.bodySmall.copyWith(
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

  CustomCard getScanCard() {
    return CustomCard(
      withBorder: true,
      onTap: () {},
      children: [
        Image.asset(
          'assets/images/ic_bill.png',
          fit: BoxFit.fitWidth,
          width: SizeConfig.safeBlockHorizontal * 10,
        ),
        Column(
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
}
