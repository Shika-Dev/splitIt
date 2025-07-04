part of 'summary_page_bloc.dart';

enum SummaryPageStatus { initial, loading, failed, success, finish }

class SummaryPageState extends Equatable {
  const SummaryPageState({
    this.status = SummaryPageStatus.initial,
    this.model,
    this.errorMessage,
  });

  final SummaryPageStatus status;
  final String? errorMessage;
  final SummaryModel? model;

  SummaryPageState copyWith({
    SummaryPageStatus? status,
    SummaryModel? model,
    String? errorMessage,
  }) => SummaryPageState(
    status: status ?? this.status,
    model: model ?? this.model,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, model, errorMessage];
}
