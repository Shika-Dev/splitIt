import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';

part 'homepage_event.dart';
part 'homepage_state.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  final HomepageUsecase usecase;
  HomepageBloc({required this.usecase}) : super(HomepageState()) {
    on<HomepageInit>(_homepageInitial);
    on<HomepageDispose>(_homepageDispose);
  }

  Future<void> _homepageInitial(
    HomepageInit event,
    Emitter<HomepageState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HomepageStatus.loading));
      final summaries = await usecase.getAllSummary();
      emit(
        state.copyWith(status: HomepageStatus.success, summaries: summaries),
      );
    } catch (e) {
      emit(state.copyWith(status: HomepageStatus.success, errorMessage: '$e'));
    }
  }

  Future<void> _homepageDispose(
    HomepageDispose event,
    Emitter<HomepageState> emit,
  ) async {
    emit(state.copyWith(status: HomepageStatus.finish));
  }
}
