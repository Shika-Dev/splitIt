part of 'homepage_bloc.dart';

sealed class HomepageEvent extends Equatable {
  const HomepageEvent();

  @override
  List<Object> get props => [];
}

class HomepageInit extends HomepageEvent {}

class HomepageDispose extends HomepageEvent {}
