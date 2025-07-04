part of 'split_bill_bloc.dart';

enum SplitBillStatus { initial, loading, success, failed, finish }

class SplitBillState extends Equatable {
  const SplitBillState({
    this.status = SplitBillStatus.initial,
    this.model,
    this.selectedUser,
    this.errorMessage,
    this.id = '',
    this.isDispose = false,
  });

  final SplitBillStatus status;
  final SplitBillModel? model;
  final String? errorMessage;
  final UserModel? selectedUser;
  final String id;
  final bool isDispose;

  SplitBillState copyWith({
    SplitBillStatus? status,
    SplitBillModel? model,
    UserModel? selectedUser,
    String? errorMessage,
    String? id,
    bool? isDispose,
  }) {
    return SplitBillState(
      status: status ?? this.status,
      model: model ?? this.model,
      selectedUser: selectedUser ?? this.selectedUser,
      errorMessage: errorMessage ?? this.errorMessage,
      id: id ?? this.id,
      isDispose: isDispose ?? this.isDispose,
    );
  }

  @override
  List<Object?> get props => [
    status,
    model,
    selectedUser,
    errorMessage,
    id,
    isDispose,
  ];
}
