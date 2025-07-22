import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group("Summary Page Bloc Test", () {
    late MockSummaryUsecase mockUsecase;
    late SummaryPageBloc bloc;

    setUp(() {
      mockUsecase = MockSummaryUsecase();
      bloc = SummaryPageBloc(usecase: mockUsecase);
    });

    tearDown(() {
      bloc.close();
    });

    group("Init Summary Page", () {
      test('Initial state is correct', () {
        expect(bloc.state.status, equals(SummaryPageStatus.initial));
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.model, isNull);
      });

      blocTest<SummaryPageBloc, SummaryPageState>(
        'emit [loading, success] when successfully get the data',
        build: () {
          final model = SummaryModel(
            id: "summaryId",
            billName: "Shop",
            userList: [],
            summaryList: [],
            currency: "\$",
            dateIssued: "dateIssued",
          );
          when(mockUsecase.getSummary(any)).thenAnswer((_) async => model);
          return bloc;
        },
        act: (bloc) => bloc.add(SummaryPageInitial(id: 'summaryId')),
        expect: () => [
          isA<SummaryPageState>().having(
            (s) => s.status,
            "status",
            SummaryPageStatus.loading,
          ),
          isA<SummaryPageState>()
              .having((s) => s.status, "status", SummaryPageStatus.success)
              .having((s) => s.model, "model", isNotNull)
              .having((s) => s.errorMessage, "error Message", isNull),
        ],
      );

      blocTest<SummaryPageBloc, SummaryPageState>(
        'emit [loading, failed] when failed get the data',
        build: () {
          when(
            mockUsecase.getSummary(any),
          ).thenThrow((Exception("Error when getting the data")));
          return bloc;
        },
        act: (bloc) => bloc.add(SummaryPageInitial(id: 'summaryId')),
        expect: () => [
          isA<SummaryPageState>().having(
            (s) => s.status,
            "status",
            SummaryPageStatus.loading,
          ),
          isA<SummaryPageState>()
              .having((s) => s.status, "status", SummaryPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                "error Message",
                "Exception: Error when getting the data",
              ),
        ],
      );
    });

    group("Dispose Summary Page", () {
      blocTest<SummaryPageBloc, SummaryPageState>(
        'emit [finish] when dispose the page',
        build: () {
          final model = SummaryModel(
            id: "summaryId",
            billName: "Shop",
            userList: [],
            summaryList: [],
            currency: "\$",
            dateIssued: "dateIssued",
          );

          when(mockUsecase.getSummary(any)).thenAnswer((_) async => model);

          bloc.emit(
            bloc.state.copyWith(
              status: SummaryPageStatus.success,
              model: model,
            ),
          );

          return bloc;
        },
        act: (bloc) => bloc.add(SummaryPageDispose()),
        expect: () => [
          isA<SummaryPageState>().having(
            (s) => s.status,
            "status",
            SummaryPageStatus.finish,
          ),
        ],
      );
    });
  });
}
