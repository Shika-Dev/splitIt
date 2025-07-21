import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';
import 'package:split_it/Presentation/split_bill/bloc/split_bill_bloc.dart';
import 'package:split_it/Presentation/split_bill/view/split_bill_page.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';
import 'package:split_it/Presentation/summary_page/view/summary_page_view.dart';
import 'package:split_it/Domain/Models/bill_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'dart:async';

class MockSplitBillBloc extends MockBloc<SplitBillEvent, SplitBillState>
    implements SplitBillBloc {}

class MockSummaryUsecase extends Mock implements SummaryUsecase {}

class MockHomepageUsecase extends Mock implements HomepageUsecase {}

class FakeSplitBillPageDispose extends Fake implements SplitBillPageDispose {}

class FakeCalculateSummary extends Fake implements CalculateSummary {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSplitBillPageDispose());
    registerFallbackValue(FakeCalculateSummary());
  });
  group('SplitBill Widget Test', () {
    late MockSplitBillBloc mockBloc;
    late MockHomepageUsecase mockUsecase;
    late MockSummaryUsecase mockSummaryUsecase;
    late GetIt getIt;

    setUp(() {
      mockBloc = MockSplitBillBloc();
      mockUsecase = MockHomepageUsecase();
      mockSummaryUsecase = MockSummaryUsecase();
      getIt = GetIt.instance;

      // Register the mock usecase
      getIt.registerSingleton<HomepageUsecase>(mockUsecase);
      getIt.registerLazySingleton<SummaryUsecase>(() => mockSummaryUsecase);

      // Register the HomepageBloc with the mock usecase
      getIt.registerFactory<HomepageBloc>(
        () => HomepageBloc(usecase: getIt<HomepageUsecase>()),
      );
      getIt.registerFactory<SummaryPageBloc>(
        () => SummaryPageBloc(usecase: getIt<SummaryUsecase>()),
      );
    });

    tearDown(() {
      getIt.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SplitBillBloc>.value(
          value: mockBloc,
          child: SplitBillPageView(),
        ),
      );
    }

    testWidgets('shows loading indicator and text when status is loading', (
      WidgetTester tester,
    ) async {
      final loadingState = const SplitBillState(
        status: SplitBillStatus.loading,
      );
      when(() => mockBloc.state).thenReturn(loadingState);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([loadingState]),
        initialState: loadingState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Lottie), findsOneWidget);
    });

    testWidgets('shows error message when status is failed', (
      WidgetTester tester,
    ) async {
      final failedState = const SplitBillState(
        status: SplitBillStatus.failed,
        errorMessage: 'Test error',
      );
      when(() => mockBloc.state).thenReturn(failedState);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([failedState]),
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
      final user = UserModel(id: 'u1', name: 'Alice', image: '');
      final item = BillElementModel(
        name: 'Pizza',
        quantity: 2,
        price: 20,
        userIds: ['u1'],
      );
      final billModel = BillModel(
        items: [item],
        subtotal: 40,
        service: 4,
        tax: 2,
        discount: 1,
        total: 45,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel,
      );
      final successState = SplitBillState(
        status: SplitBillStatus.success,
        model: model,
        selectedUser: user,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Alice'), findsAtLeast(1));
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text(' 24 20'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Service Charge'), findsOneWidget);
      expect(find.text('Tax'), findsOneWidget);
      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Calculate'), findsOneWidget);
    });

    testWidgets('navigates to HomePage when status is finish and id is empty', (
      WidgetTester tester,
    ) async {
      final finishState = const SplitBillState(
        status: SplitBillStatus.finish,
        id: '',
      );
      when(() => mockBloc.state).thenReturn(finishState);

      when(() => mockUsecase.getAllSummary()).thenAnswer((_) async => []);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([finishState]),
        initialState: finishState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets(
      'navigates to SummaryPage when status is finish and id is not empty',
      (WidgetTester tester) async {
        final finishState = const SplitBillState(
          status: SplitBillStatus.finish,
          id: 'summary123',
        );
        final summaryModel = SummaryModel(
          id: 'summary123',
          billName: "billName",
          userList: [],
          summaryList: [],
          currency: "currency",
          dateIssued: "dateIssued",
        );

        when(
          () => mockSummaryUsecase.getSummary('summary123'),
        ).thenAnswer((_) async => summaryModel);

        when(() => mockBloc.state).thenReturn(finishState);

        whenListen(
          mockBloc,
          Stream<SplitBillState>.fromIterable([finishState]),
          initialState: finishState,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SummaryPage), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is SummaryPage && widget.id == 'summary123',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping Cancel button triggers SplitBillPageDispose event', (
      WidgetTester tester,
    ) async {
      final user = UserModel(id: 'u1', name: 'Alice', image: '');
      final billModel = BillModel(
        items: [],
        subtotal: 0,
        service: 0,
        tax: 0,
        discount: 0,
        total: 0,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel,
      );
      final successState = SplitBillState(
        status: SplitBillStatus.success,
        model: model,
        selectedUser: user,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      verify(
        () => mockBloc.add(any(that: isA<SplitBillPageDispose>())),
      ).called(1);
    });

    testWidgets('tapping Calculate button triggers CalculateSummary event', (
      WidgetTester tester,
    ) async {
      final user = UserModel(id: 'u1', name: 'Alice', image: '');
      final billModel = BillModel(
        items: [],
        subtotal: 0,
        service: 0,
        tax: 0,
        discount: 0,
        total: 0,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel,
      );
      final successState = SplitBillState(
        status: SplitBillStatus.success,
        model: model,
        selectedUser: user,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<SplitBillState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Calculate'));
      await tester.pump();
      verify(() => mockBloc.add(any(that: isA<CalculateSummary>()))).called(1);
    });

    testWidgets('tapping add user button adds a new user to the UI', (
      WidgetTester tester,
    ) async {
      final user1 = UserModel(id: 'u1', name: 'Alice', image: '');
      final billModel = BillModel(
        items: [],
        subtotal: 0,
        service: 0,
        tax: 0,
        discount: 0,
        total: 0,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model1 = SplitBillModel(
        id: 'b1',
        users: [user1],
        billModel: billModel,
      );
      final user2 = UserModel(id: 'u2', name: 'Bob', image: '');
      final model2 = SplitBillModel(
        id: 'b1',
        users: [user1, user2],
        billModel: billModel,
      );
      final state1 = SplitBillState(
        status: SplitBillStatus.success,
        model: model1,
        selectedUser: user1,
      );
      final state2 = SplitBillState(
        status: SplitBillStatus.success,
        model: model2,
        selectedUser: user2,
      );

      final controller = StreamController<SplitBillState>();
      addTearDown(() => controller.close());
      whenListen(mockBloc, controller.stream, initialState: state1);
      when(() => mockBloc.state).thenReturn(state1);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));

      controller.add(state2);
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('editing user name triggers UpdateUserName event', (
      WidgetTester tester,
    ) async {
      final user = UserModel(id: 'u1', name: 'Alice', image: '');
      final updatedUser = UserModel(id: 'u1', name: 'Bob', image: '');
      final billModel = BillModel(
        items: [],
        subtotal: 0,
        service: 0,
        tax: 0,
        discount: 0,
        total: 0,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model1 = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel,
      );
      final model2 = SplitBillModel(
        id: 'b1',
        users: [updatedUser],
        billModel: billModel,
      );
      final state1 = SplitBillState(
        status: SplitBillStatus.success,
        model: model1,
        selectedUser: user,
      );
      final state2 = SplitBillState(
        status: SplitBillStatus.success,
        model: model2,
        selectedUser: updatedUser,
      );

      final controller = StreamController<SplitBillState>();
      addTearDown(() => controller.close());
      whenListen(mockBloc, controller.stream, initialState: state1);
      when(() => mockBloc.state).thenReturn(state1);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'Bob');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      controller.add(state2);
      await tester.pump();

      expect(find.text("Alice"), findsNothing);
      expect(find.text("Bob"), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('tapping bill item assigns/removes user from bill item', (
      WidgetTester tester,
    ) async {
      final user = UserModel(id: 'u1', name: 'Alice', image: '');
      final item1 = BillElementModel(
        name: 'Pizza',
        quantity: 2,
        price: 20,
        userIds: [],
      );
      final item2 = BillElementModel(
        name: 'Pizza',
        quantity: 2,
        price: 20,
        userIds: ['u1'],
      );
      final billModel1 = BillModel(
        items: [item1],
        subtotal: 40,
        service: 4,
        tax: 2,
        discount: 1,
        total: 45,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final billModel2 = BillModel(
        items: [item2],
        subtotal: 40,
        service: 4,
        tax: 2,
        discount: 1,
        total: 45,
        billName: 'Dinner',
        currency: ' 24',
        dateIssued: '2024-01-01',
      );
      final model1 = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel1,
      );
      final model2 = SplitBillModel(
        id: 'b1',
        users: [user],
        billModel: billModel2,
      );
      final notSelectedState = SplitBillState(
        status: SplitBillStatus.success,
        model: model1,
        selectedUser: user,
      );
      final selectedState = SplitBillState(
        status: SplitBillStatus.success,
        model: model2,
        selectedUser: user,
      );

      final controller = StreamController<SplitBillState>();
      addTearDown(() => controller.close());
      whenListen(mockBloc, controller.stream, initialState: notSelectedState);
      when(() => mockBloc.state).thenReturn(notSelectedState);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Pizza'));
      controller.add(selectedState);
      await tester.pump();

      expect(find.text("Alice"), findsNWidgets(2));

      await tester.tap(find.text('Pizza'));
      controller.add(notSelectedState);
      await tester.pump();

      expect(find.text("Alice"), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
