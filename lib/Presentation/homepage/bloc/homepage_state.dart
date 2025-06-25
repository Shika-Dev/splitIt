part of 'homepage_bloc.dart';

sealed class HomepageState extends Equatable {
  const HomepageState();
  
  @override
  List<Object> get props => [];
}

final class HomepageInitial extends HomepageState {}
