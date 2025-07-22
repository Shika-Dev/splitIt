import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';
import 'package:split_it/Presentation/summary_page/view/summary_page_view.dart';

class MockSummaryPageBloc extends MockBloc<SummaryPageEvent, SummaryPageState>
    implements SummaryPageBloc {}

class MockHomepageUsecase extends Mock implements HomepageUsecase {}

void main() {
  late MockSummaryPageBloc mockBloc;
  late MockHomepageUsecase mockHomePageUsecase;
  late GetIt getIt;
  group('Summary Page View Test Using Mock Bloc', () {
    setUp(() {
      mockBloc = MockSummaryPageBloc();
      mockHomePageUsecase = MockHomepageUsecase();
      getIt = GetIt.instance;

      getIt.registerSingleton<HomepageUsecase>(mockHomePageUsecase);

      getIt.registerFactory<HomepageBloc>(
        () => HomepageBloc(usecase: getIt<HomepageUsecase>()),
      );
    });

    tearDown(() {
      mockBloc.close();
      getIt.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SummaryPageBloc>.value(
          value: mockBloc,
          child: SummaryPageView(),
        ),
      );
    }

    testWidgets('shows loading indicator and text when status is loading', (
      WidgetTester tester,
    ) async {
      final loadingState = const SummaryPageState(
        status: SummaryPageStatus.loading,
      );
      when(() => mockBloc.state).thenReturn(loadingState);
      whenListen(
        mockBloc,
        Stream<SummaryPageState>.fromIterable([loadingState]),
        initialState: loadingState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Lottie), findsOneWidget);
    });

    testWidgets('shows error message when status is failed', (
      WidgetTester tester,
    ) async {
      final failedState = const SummaryPageState(
        status: SummaryPageStatus.failed,
        errorMessage: 'Test error',
      );
      when(() => mockBloc.state).thenReturn(failedState);
      whenListen(
        mockBloc,
        Stream<SummaryPageState>.fromIterable([failedState]),
        initialState: failedState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Lottie), findsOneWidget);
      expect(find.textContaining('Test error'), findsOneWidget);
    });

    testWidgets('shows main content when status is success', (
      WidgetTester tester,
    ) async {
      final user = UserModel(id: "me", name: "Alice", image: "");
      final item = SummaryItemModel(
        userId: "me",
        totalOwned: 1,
        items: ["Rice"],
      );
      final model = SummaryModel(
        id: "summaryId",
        billName: "Shope",
        userList: [user],
        summaryList: [item],
        currency: "\$",
        dateIssued: "08/09/20025",
      );

      final successState = SummaryPageState(
        status: SummaryPageStatus.success,
        model: model,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<SummaryPageState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Shope'), findsOneWidget);
      expect(find.text('Alice'), findsAtLeast(1));
      expect(find.text('- Rice'), findsOneWidget);
      expect(find.text('\$ 1'), findsOneWidget);
    });

    testWidgets('navigates to HomePage when status is finish', (
      WidgetTester tester,
    ) async {
      final finishState = const SummaryPageState(
        status: SummaryPageStatus.finish,
      );
      when(() => mockBloc.state).thenReturn(finishState);

      when(
        () => mockHomePageUsecase.getAllSummary(),
      ).thenAnswer((_) async => []);
      whenListen(
        mockBloc,
        Stream<SummaryPageState>.fromIterable([finishState]),
        initialState: finishState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
