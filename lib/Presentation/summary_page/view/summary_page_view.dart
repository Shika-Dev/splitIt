import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class SummaryPage extends StatelessWidget {
  final String id;
  const SummaryPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<SummaryPageBloc>()..add(SummaryPageInitial(id: id)),
      child: SummaryPageView(),
    );
  }
}

class SummaryPageView extends StatelessWidget {
  const SummaryPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<SummaryPageBloc, SummaryPageState>(
          listener: (context, state) {
            if (state.status == SummaryPageStatus.finish) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state.status == SummaryPageStatus.loading) {
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
            if (state.status == SummaryPageStatus.failed) {
              return Center(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.read<SummaryPageBloc>().add(
                          SummaryPageDispose(),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: CustomTheme.textColor,
                        ),
                      ),
                      Spacer(),
                      Text('Summary', style: CustomTheme.h3),
                      Spacer(),
                    ],
                  ),
                  VerticalSeparator(height: 3),
                  Text(state.model?.billName ?? '', style: CustomTheme.h3),
                  VerticalSeparator(height: 3),
                  SizedBox(
                    height: 83,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        return getUserWidget(state, index);
                      },
                      separatorBuilder: (_, __) =>
                          HorizontalSeparator(width: 3),
                      itemCount: (state.model?.userList.length ?? 0),
                    ),
                  ),
                  VerticalSeparator(height: 3),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, index) {
                        return getSummaryListWidget(state, index);
                      },
                      separatorBuilder: (_, __) => VerticalSeparator(height: 1),
                      itemCount: (state.model?.summaryList.length ?? 0),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getUserWidget(SummaryPageState state, int index) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.primaryColor,
          ),
          child: Center(
            child: Icon(Icons.person, color: CustomTheme.textColor, size: 30),
          ),
        ),
        SizedBox(height: 3),
        Text(
          state.model?.userList[index].name ?? '',
          style: CustomTheme.bodySmall,
        ),
      ],
    );
  }

  Widget getSummaryListWidget(SummaryPageState state, int index) {
    final summary = state.model?.summaryList[index];
    final user = state.model?.userList.firstWhere(
      (e) => e.id == summary?.userId,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.primaryColor,
          ),
          child: Center(
            child: Icon(Icons.person, color: CustomTheme.textColor, size: 30),
          ),
        ),
        HorizontalSeparator(width: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.name ?? '', style: CustomTheme.bodySmall),

            SizedBox(
              width: SizeConfig.safeBlockHorizontal * 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: (summary?.items ?? [])
                    .map(
                      (e) => Text(
                        '- $e',
                        style: CustomTheme.captionLarge.copyWith(
                          color: CustomTheme.textColor.withValues(alpha: .67),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        Text('${summary?.totalOwned ?? 0}', style: CustomTheme.bodySmall),
      ],
    );
  }
}
