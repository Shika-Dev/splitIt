import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';

part 'summary_page_event.dart';
part 'summary_page_state.dart';

class SummaryPageBloc extends Bloc<SummaryPageEvent, SummaryPageState> {
  final SummaryUsecase usecase;
  SummaryPageBloc({required this.usecase}) : super(SummaryPageState()) {
    on<SummaryPageInitial>(_summaryPageInitial);
    on<SummaryPageDispose>(_summaryPageDispose);
  }

  Future<void> _summaryPageInitial(
    SummaryPageInitial event,
    Emitter<SummaryPageState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SummaryPageStatus.loading));
      final summary = await usecase.getSummary(event.id);
      emit(state.copyWith(status: SummaryPageStatus.success, model: summary));
    } catch (e) {
      emit(
        state.copyWith(status: SummaryPageStatus.failed, errorMessage: '$e'),
      );
    }
  }

  Future<void> _summaryPageDispose(
    SummaryPageDispose event,
    Emitter<SummaryPageState> emit,
  ) async {
    emit(state.copyWith(status: SummaryPageStatus.finish));
  }
}
