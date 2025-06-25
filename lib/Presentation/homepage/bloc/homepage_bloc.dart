import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'homepage_event.dart';
part 'homepage_state.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  HomepageBloc() : super(HomepageInitial()) {
    on<HomepageEvent>((event, emit) => _homepageInitial(event, emit));
  }

  Future<void> _homepageInitial(
    HomepageEvent event,
    Emitter<HomepageState> emit,
  ) async {}
}
