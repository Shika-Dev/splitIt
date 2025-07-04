part of 'homepage_bloc.dart';

sealed class HomepageEvent extends Equatable {
  const HomepageEvent();

  @override
  List<Object> get props => [];
}

class HomepageInit extends HomepageEvent {}

class HomepageDispose extends HomepageEvent {}

class DeleteSummary extends HomepageEvent {
  final String id;

  const DeleteSummary({required this.id});

  @override
  List<Object> get props => [id];
}
