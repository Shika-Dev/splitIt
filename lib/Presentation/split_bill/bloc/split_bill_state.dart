part of 'split_bill_bloc.dart';

enum SplitBillStatus { initial, loading, success, failed, finish }

class SplitBillState extends Equatable {
  const SplitBillState({
    this.status = SplitBillStatus.initial,
    this.model,
    this.selectedUser,
    this.errorMessage,
  });

  final SplitBillStatus status;
  final SplitBillModel? model;
  final String? errorMessage;
  final UserModel? selectedUser;

  SplitBillState copyWith({
    SplitBillStatus? status,
    SplitBillModel? model,
    UserModel? selectedUser,
    String? errorMessage,
  }) {
    return SplitBillState(
      status: status ?? this.status,
      model: model ?? this.model,
      selectedUser: selectedUser ?? this.selectedUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, model, selectedUser, errorMessage];
}
