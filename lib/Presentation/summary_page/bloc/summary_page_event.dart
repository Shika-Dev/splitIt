part of 'summary_page_bloc.dart';

sealed class SummaryPageEvent extends Equatable {
  const SummaryPageEvent();

  @override
  List<Object> get props => [];
}

class SummaryPageInitial extends SummaryPageEvent {
  final String id;
  const SummaryPageInitial({required this.id});

  @override
  List<Object> get props => [id];
}

class SummaryPageDispose extends SummaryPageEvent {}
