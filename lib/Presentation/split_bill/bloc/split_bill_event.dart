part of 'split_bill_bloc.dart';

sealed class SplitBillEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitSplitBillPage extends SplitBillEvent {
  final String id;
  InitSplitBillPage({required this.id});
}

class SplitBillPageDispose extends SplitBillEvent {}

class AddUserToSplitBill extends SplitBillEvent {
  final String name;
  AddUserToSplitBill({required this.name});

  @override
  List<Object> get props => [name];
}

class UpdateUserName extends SplitBillEvent {
  final String userId;
  final String name;
  UpdateUserName({required this.userId, required this.name});

  @override
  List<Object> get props => [userId, name];
}

class UpdateSelectedUser extends SplitBillEvent {
  final String userId;

  UpdateSelectedUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AssignUserToBillItem extends SplitBillEvent {
  final int itemIndex;
  final String userId;
  AssignUserToBillItem({required this.itemIndex, required this.userId});

  @override
  List<Object> get props => [itemIndex, userId];
}

class CalculateSummary extends SplitBillEvent {
  @override
  List<Object> get props => [];
}
