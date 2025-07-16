import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('HomepageBloc', () {
    late MockHomepageUsecase mockUsecase;
    late HomepageBloc bloc;

    setUp(() {
      mockUsecase = MockHomepageUsecase();
      bloc = HomepageBloc(usecase: mockUsecase);
    });

    tearDown(() {
      bloc.close();
    });

    group('HomepageInit', () {
      test('initial state is correct', () {
        expect(bloc.state.status, equals(HomepageStatus.initial));
        expect(bloc.state.summaries, isEmpty);
        expect(bloc.state.errorMessage, isNull);
      });

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, success] when initialization is successful',
        build: () {
          final mockSummaries = [
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
            SummaryModel(
              id: '2',
              billName: 'Test Bill 2',
              userList: [UserModel(id: 'user3', name: 'Bob', image: 'image3')],
              summaryList: [
                SummaryItemModel(
                  userId: 'user3',
                  totalOwned: 15.0,
                  items: ['Item 4'],
                ),
              ],
              currency: '\$',
              dateIssued: '2024-01-02',
            ),
          ];

          when(
            mockUsecase.getAllSummary(),
          ).thenAnswer((_) async => mockSummaries);
          return bloc;
        },
        act: (bloc) => bloc.add(HomepageInit()),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries.length, 'summaries length', 2)
              .having(
                (s) => s.summaries[0].billName,
                'first bill name',
                'Test Bill 1',
              )
              .having(
                (s) => s.summaries[1].billName,
                'second bill name',
                'Test Bill 2',
              ),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, success] with empty list when no summaries exist',
        build: () {
          when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(HomepageInit()),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries, 'summaries', isEmpty),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, failed] with error message when exception occurs',
        build: () {
          when(
            mockUsecase.getAllSummary(),
          ).thenThrow(Exception('Database connection failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(HomepageInit()),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Exception: Database connection failed',
              ),
        ],
      );
    });

    group('HomepageDispose', () {
      blocTest<HomepageBloc, HomepageState>(
        'emits [finish] when dispose is called',
        build: () => bloc,
        act: (bloc) => bloc.add(HomepageDispose()),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.finish,
          ),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [finish] when dispose is called from any state',
        build: () {
          // Set initial state with some data
          bloc.emit(
            bloc.state.copyWith(
              status: HomepageStatus.success,
              summaries: [
                SummaryModel(
                  id: '1',
                  billName: 'Test Bill',
                  userList: [],
                  summaryList: [],
                  currency: '\$',
                  dateIssued: '2024-01-01',
                ),
              ],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(HomepageDispose()),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.finish,
          ),
        ],
      );
    });

    group('DeleteSummary', () {
      final testSummaryId = 'test-id-123';

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, success] when deletion is successful',
        build: () {
          final remainingSummaries = [
            SummaryModel(
              id: '2',
              billName: 'Remaining Bill',
              userList: [UserModel(id: 'user1', name: 'John', image: 'image1')],
              summaryList: [
                SummaryItemModel(
                  userId: 'user1',
                  totalOwned: 20.0,
                  items: ['Item 1'],
                ),
              ],
              currency: '\$',
              dateIssued: '2024-01-02',
            ),
          ];

          when(
            mockUsecase.deleteSummary(testSummaryId),
          ).thenAnswer((_) async {});
          when(
            mockUsecase.getAllSummary(),
          ).thenAnswer((_) async => remainingSummaries);
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteSummary(id: testSummaryId)),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries.length, 'summaries length', 1)
              .having(
                (s) => s.summaries[0].billName,
                'bill name',
                'Remaining Bill',
              ),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, success] with empty list when last summary is deleted',
        build: () {
          when(
            mockUsecase.deleteSummary(testSummaryId),
          ).thenAnswer((_) async {});
          when(mockUsecase.getAllSummary()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteSummary(id: testSummaryId)),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries, 'summaries', isEmpty),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, failed] with error message when deletion fails',
        build: () {
          when(
            mockUsecase.deleteSummary(testSummaryId),
          ).thenThrow(Exception('Summary not found'));
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteSummary(id: testSummaryId)),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Exception: Summary not found',
              ),
        ],
      );

      blocTest<HomepageBloc, HomepageState>(
        'emits [loading, failed] with error message when getAllSummary fails after deletion',
        build: () {
          when(
            mockUsecase.deleteSummary(testSummaryId),
          ).thenAnswer((_) async {});
          when(
            mockUsecase.getAllSummary(),
          ).thenThrow(Exception('Failed to refresh summaries'));
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteSummary(id: testSummaryId)),
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Exception: Failed to refresh summaries',
              ),
        ],
      );

      test('DeleteSummary event has correct props', () {
        const event = DeleteSummary(id: 'test-id');
        expect(event.props, equals(['test-id']));
      });
    });

    group('State Management', () {
      test('copyWith creates new state with updated values', () {
        final initialState = HomepageState();
        final updatedState = initialState.copyWith(
          status: HomepageStatus.success,
          summaries: [
            SummaryModel(
              id: '1',
              billName: 'Test Bill',
              userList: [],
              summaryList: [],
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          ],
          errorMessage: 'Test error',
        );

        expect(updatedState.status, equals(HomepageStatus.success));
        expect(updatedState.summaries.length, equals(1));
        expect(updatedState.errorMessage, equals('Test error'));
        expect(updatedState, isNot(same(initialState)));
      });

      test('copyWith preserves existing values when not specified', () {
        final initialState = HomepageState(
          status: HomepageStatus.success,
          summaries: [
            SummaryModel(
              id: '1',
              billName: 'Test Bill',
              userList: [],
              summaryList: [],
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          ],
          errorMessage: 'Test error',
        );

        final updatedState = initialState.copyWith(
          status: HomepageStatus.finish,
        );

        expect(updatedState.status, equals(HomepageStatus.finish));
        expect(updatedState.summaries, equals(initialState.summaries));
        expect(updatedState.errorMessage, equals(initialState.errorMessage));
      });

      test('state props contain all relevant fields', () {
        final state = HomepageState(
          status: HomepageStatus.success,
          summaries: [],
          errorMessage: 'Test error',
        );

        expect(state.props, equals([HomepageStatus.success, [], 'Test error']));
      });
    });

    group('Integration Tests', () {
      blocTest<HomepageBloc, HomepageState>(
        'handles multiple operations in sequence correctly',
        build: () {
          final initialSummaries = [
            SummaryModel(
              id: '1',
              billName: 'Bill 1',
              userList: [],
              summaryList: [],
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
            SummaryModel(
              id: '2',
              billName: 'Bill 2',
              userList: [],
              summaryList: [],
              currency: '\$',
              dateIssued: '2024-01-02',
            ),
          ];

          final afterDeleteSummaries = [
            SummaryModel(
              id: '2',
              billName: 'Bill 2',
              userList: [],
              summaryList: [],
              currency: '\$',
              dateIssued: '2024-01-02',
            ),
          ];

          int callCount = 0;
          when(mockUsecase.getAllSummary()).thenAnswer((_) async {
            callCount++;
            return callCount == 1 ? initialSummaries : afterDeleteSummaries;
          });
          when(mockUsecase.deleteSummary('1')).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) {
          bloc.add(HomepageInit());
          bloc.add(DeleteSummary(id: '1'));
        },
        expect: () => [
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries.length, 'summaries length', 2),
          isA<HomepageState>().having(
            (s) => s.status,
            'status',
            HomepageStatus.loading,
          ),
          isA<HomepageState>()
              .having((s) => s.status, 'status', HomepageStatus.success)
              .having((s) => s.summaries.length, 'summaries length', 1),
        ],
      );
    });
  });
}
