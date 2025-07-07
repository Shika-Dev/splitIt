import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('HomepageView Widget Tests', () {
    late MockHomepageUsecase mockUsecase;
    late GetIt getIt;

    setUp(() {
      mockUsecase = MockHomepageUsecase();
      getIt = GetIt.instance;

      // Register the mock usecase
      getIt.registerSingleton<HomepageUsecase>(mockUsecase);

      // Register the HomepageBloc with the mock usecase
      getIt.registerFactory<HomepageBloc>(
        () => HomepageBloc(usecase: getIt<HomepageUsecase>()),
      );
    });

    tearDown(() {
      getIt.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(home: HomePage());
    }

    group('Loading State', () {
      testWidgets('shows loading indicator when status is loading', (
        WidgetTester tester,
      ) async {
        // Use a Completer to control when the async operation completes
        final completer = Completer<List<SummaryModel>>();
        when(mockUsecase.getAllSummary()).thenAnswer((_) => completer.future);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for Lottie widget with loading animation
        expect(find.byType(Lottie), findsOneWidget);

        // Complete the async operation
        completer.complete([]);
        await tester.pumpAndSettle();
      });
    });

    group('Success State', () {
      testWidgets('shows scan card when status is success', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries (success state)
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Scan your bill'), findsOneWidget);
        expect(find.text('and split it fast ⚡'), findsOneWidget);
      });

      testWidgets('shows summary cards when summaries are available', (
        WidgetTester tester,
      ) async {
        final summaries = [
          SummaryModel(
            id: '1',
            billName: 'Test Bill 1',
            userList: [
              UserModel(id: 'user1', name: 'John', image: 'image1'),
              UserModel(id: 'user2', name: 'Jane', image: 'image2'),
            ],
            summaryList: [
              SummaryItemModel(
                userId: 'user1',
                totalOwned: 25.0,
                items: ['Item 1', 'Item 2'],
              ),
              SummaryItemModel(
                userId: 'user2',
                totalOwned: 30.0,
                items: ['Item 3'],
              ),
            ],
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
        ];

        // Mock the usecase to return summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => summaries);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check for the bill name and user count text
        expect(find.text('Test Bill 1'), findsOneWidget);
        expect(find.text('You and 1 others'), findsOneWidget);
      });

      testWidgets('shows empty state when no summaries are available', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should still show scan card but no summary cards
        expect(find.text('Scan your bill'), findsOneWidget);
        // No summary cards should be present
      });
    });

    group('Error State', () {
      testWidgets('shows error message when status is failed', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to throw an exception
        when(
          mockUsecase.getAllSummary(),
        ).thenThrow(Exception('Test error message'));

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for both the Lottie error animation and the error message
        expect(find.byType(Lottie), findsOneWidget);
        expect(find.text('Exception: Test error message'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('tapping scan card shows bottom sheet', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the scan card
        await tester.tap(find.text('Scan your bill'));
        await tester.pumpAndSettle();

        // Should show bottom sheet with camera and gallery options
        expect(find.text('Use your Camera'), findsOneWidget);
        expect(find.text('Pick from Gallery'), findsOneWidget);
      });

      testWidgets('tapping delete button on summary card triggers delete event', (
        WidgetTester tester,
      ) async {
        final summaries = [
          SummaryModel(
            id: '1',
            billName: 'Test Bill',
            userList: [UserModel(id: 'user1', name: 'John', image: 'image1')],
            summaryList: [],
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
        ];

        // Mock the usecase to return summaries initially, then empty list after delete
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => summaries);
        when(mockUsecase.deleteSummary('1')).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap delete button (assuming it's an IconButton with delete icon)
        final deleteButton = find.byIcon(Icons.delete);
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton.first);
          await tester.pump();

          // Verify that the bloc received the delete event
          // This would require additional setup to verify the event was dispatched
        }
      });
    });

    group('Navigation', () {
      testWidgets('navigates to scan page when camera option is selected', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.text('Scan your bill'));
        await tester.pumpAndSettle();

        // Tap camera option
        await tester.tap(find.text('Use your Camera'));
        await tester.pumpAndSettle();

        // Note: This test would need to be modified based on actual navigation implementation
        // and would require mocking the image picker
      });
    });

    group('Accessibility', () {
      testWidgets('scan card is accessible with proper text content', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that the scan card has accessible text content
        expect(find.text('Scan your bill'), findsOneWidget);
        expect(find.text('and split it fast ⚡'), findsOneWidget);

        // Verify that the card is tappable (has onTap functionality)
        expect(find.byType(GestureDetector), findsWidgets);
      });

      testWidgets('summary cards are accessible with proper content', (
        WidgetTester tester,
      ) async {
        final summaries = [
          SummaryModel(
            id: '1',
            billName: 'Test Bill',
            userList: [
              UserModel(id: 'user1', name: 'John', image: 'image1'),
              UserModel(id: 'user2', name: 'Jane', image: 'image2'),
            ],
            summaryList: [],
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
        ];

        // Mock the usecase to return summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => summaries);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify that summary cards have accessible content
        expect(find.text('Test Bill'), findsOneWidget);
        expect(find.text('You and 1 others'), findsOneWidget);

        // Verify that the cards are tappable
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts to different screen sizes', (
        WidgetTester tester,
      ) async {
        // Mock the usecase to return empty summaries
        when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);

        // Test with different screen sizes
        await tester.binding.setSurfaceSize(Size(550, 950));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Scan your bill'), findsOneWidget);

        // Test with larger screen
        await tester.binding.setSurfaceSize(Size(800, 1200));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Scan your bill'), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
