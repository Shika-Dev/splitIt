part of 'homepage_bloc.dart';

enum HomepageStatus { initial, loading, failed, success, finish }

class HomepageState extends Equatable {
  const HomepageState({
    this.status = HomepageStatus.initial,
    this.summaries = const <SummaryModel>[],
    this.errorMessage,
  });

  final HomepageStatus status;
  final String? errorMessage;
  final List<SummaryModel> summaries;

  HomepageState copyWith({
    HomepageStatus? status,
    List<SummaryModel>? summaries,
    String? errorMessage,
  }) => HomepageState(
    status: status ?? this.status,
    summaries: summaries ?? this.summaries,
    errorMessage: errorMessage ?? this.errorMessage,
  );
  @override
  List<Object?> get props => [status, summaries, errorMessage];
}
