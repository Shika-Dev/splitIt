import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Presentation/scan_page/view/scan_page_view.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';

class MockScanPageBloc extends MockBloc<ScanPageEvent, ScanPageState>
    implements ScanPageBloc {}

void main() {
  group('ScanPageView Widget Tests (with MockBloc)', () {
    late MockScanPageBloc mockBloc;

    setUp(() {
      mockBloc = MockScanPageBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<ScanPageBloc>.value(
          value: mockBloc,
          child: ScanPageView(),
        ),
      );
    }

    testWidgets('shows loading indicator and text when status is loading', (
      WidgetTester tester,
    ) async {
      final loadingState = const ScanPageState(status: ScanPageStatus.loading);
      when(() => mockBloc.state).thenReturn(loadingState);
      whenListen(
        mockBloc,
        Stream<ScanPageState>.fromIterable([loadingState]),
        initialState: loadingState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Lottie), findsOneWidget);
      expect(
        find.textContaining('Please wait while we analyze'),
        findsOneWidget,
      );
    });

    testWidgets('shows bill details and items when status is success', (
      WidgetTester tester,
    ) async {
      final mockBillItem = BillItemModel(
        items: [
          BillItem(name: 'Burger', quantity: 2, price: 5.0),
          BillItem(name: 'Fries', quantity: 1, price: 3.0),
        ],
        subtotal: 13.0,
        service: 1.0,
        tax: 0.5,
        discount: 0.0,
        total: 14.5,
        billName: 'Test Bill',
        currency: '\u0024',
        dateIssued: '2024-01-01',
      );
      final successState = ScanPageState(
        status: ScanPageStatus.success,
        billItem: mockBillItem,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<ScanPageState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Test Bill'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Fries'), findsOneWidget);
      expect(find.text('\u0024 5.0'), findsOneWidget);
      expect(find.text('\u0024 3.0'), findsOneWidget);
      expect(find.text('\u0024 13.0'), findsOneWidget); // Subtotal
      expect(find.text('\u0024 1.0'), findsOneWidget); // Service
      expect(find.text('\u0024 0.5'), findsOneWidget); // Tax
      expect(find.text('\u0024 0.0'), findsOneWidget); // Discount
      expect(find.text('\u0024 14.5'), findsOneWidget); // Total
    });

    testWidgets('shows error message and retry button when status is failed', (
      WidgetTester tester,
    ) async {
      final failedState = const ScanPageState(
        status: ScanPageStatus.failed,
        errorMessage: 'Test error',
      );
      when(() => mockBloc.state).thenReturn(failedState);
      whenListen(
        mockBloc,
        Stream<ScanPageState>.fromIterable([failedState]),
        initialState: failedState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Lottie), findsOneWidget);
      expect(find.textContaining('Test error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets(
      'shows text fields when Edit is pressed and returns to normal on Confirm',
      (WidgetTester tester) async {
        final mockBillItem = BillItemModel(
          items: [BillItem(name: 'Burger', quantity: 2, price: 5.0)],
          subtotal: 5.0,
          service: 1.0,
          tax: 0.5,
          discount: 0.0,
          total: 6.5,
          billName: 'Test Bill',
          currency: '\$',
          dateIssued: '2024-01-01',
        );
        final controllers = List.generate(8, (_) => TextEditingController());
        final notEditState = ScanPageState(
          status: ScanPageStatus.success,
          billItem: mockBillItem,
          isEdit: false,
        );
        final editState = ScanPageState(
          status: ScanPageStatus.success,
          billItem: mockBillItem,
          isEdit: true,
          controllers: controllers,
        );

        // Use a StreamController for the bloc's state stream
        final stateController = StreamController<ScanPageState>();

        when(() => mockBloc.state).thenReturn(notEditState);
        whenListen(
          mockBloc,
          stateController.stream,
          initialState: notEditState,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Simulate tapping Edit: emit editState and update the stub
        stateController.add(editState);
        when(() => mockBloc.state).thenReturn(editState);
        await tester.tap(find.text('Edit'));
        await tester.pump();

        expect(find.byType(TextFormField), findsWidgets);

        // Simulate tapping Confirm: emit notEditState and update the stub
        stateController.add(notEditState);
        when(() => mockBloc.state).thenReturn(notEditState);
        await tester.tap(find.text('Confirm'));
        await tester.pump();

        expect(find.byType(TextFormField), findsNothing);

        await stateController.close();
      },
    );

    testWidgets('bill name and items are accessible', (
      WidgetTester tester,
    ) async {
      final mockBillItem = BillItemModel(
        items: [BillItem(name: 'Burger', quantity: 2, price: 5.0)],
        subtotal: 5.0,
        service: 1.0,
        tax: 0.5,
        discount: 0.0,
        total: 6.5,
        billName: 'Test Bill',
        currency: '\u0024',
        dateIssued: '2024-01-01',
      );
      final successState = ScanPageState(
        status: ScanPageStatus.success,
        billItem: mockBillItem,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<ScanPageState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Test Bill'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
    });

    testWidgets('adapts to different screen sizes', (
      WidgetTester tester,
    ) async {
      final mockBillItem = BillItemModel(
        items: [BillItem(name: 'Burger', quantity: 2, price: 5.0)],
        subtotal: 5.0,
        service: 1.0,
        tax: 0.5,
        discount: 0.0,
        total: 6.5,
        billName: 'Test Bill',
        currency: '\u0024',
        dateIssued: '2024-01-01',
      );
      final successState = ScanPageState(
        status: ScanPageStatus.success,
        billItem: mockBillItem,
      );
      when(() => mockBloc.state).thenReturn(successState);
      whenListen(
        mockBloc,
        Stream<ScanPageState>.fromIterable([successState]),
        initialState: successState,
      );

      await tester.binding.setSurfaceSize(const Size(550, 950));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Test Bill'), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Test Bill'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
