part of 'scan_page_bloc.dart';

enum ScanPageStatus { initial, loading, failed, success }

class ScanPageState extends Equatable {
  const ScanPageState({
    this.status = ScanPageStatus.initial,
    this.billItem,
    this.errorMessage,
    this.warning,
  });

  final ScanPageStatus status;
  final BillItemModel? billItem;
  final String? errorMessage;
  final String? warning;

  ScanPageState copyWith({
    ScanPageStatus? status,
    BillItemModel? billItem,
    String? errorMessage,
    String? warning,
  }) {
    return ScanPageState(
      status: status ?? this.status,
      billItem: billItem ?? this.billItem,
      errorMessage: errorMessage ?? this.errorMessage,
      warning: warning ?? this.warning,
    );
  }

  @override
  List<Object?> get props => [status, billItem, errorMessage, warning];
}
