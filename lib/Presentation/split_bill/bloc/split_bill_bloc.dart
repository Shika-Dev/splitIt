import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Domain/Models/bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';
import 'package:uuid/uuid.dart';

part 'split_bill_event.dart';
part 'split_bill_state.dart';

class SplitBillBloc extends Bloc<SplitBillEvent, SplitBillState> {
  final SplitBillUsecase usecase;
  SplitBillBloc({required this.usecase}) : super(SplitBillState()) {
    on<InitSplitBillPage>(_initSplitBillPage);
    on<SplitBillPageDispose>(_splitBillDispose);
    on<AddUserToSplitBill>(_addUserToSplitBill);
    on<UpdateUserName>(_updateUserName);
    on<UpdateSelectedUser>(_updateSelectedUser);
    on<AssignUserToBillItem>(_assignUserToBillItem);
    on<CalculateSummary>(_calculateSummary);
  }

  Future<void> _initSplitBillPage(
    InitSplitBillPage event,
    Emitter<SplitBillState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SplitBillStatus.loading));
      final model = await usecase.getBillDetail(event.id);
      emit(
        state.copyWith(
          status: SplitBillStatus.success,
          model: model,
          selectedUser: model.users.first,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SplitBillStatus.failed, errorMessage: '$e'));
    }
  }

  Future<void> _splitBillDispose(
    SplitBillPageDispose event,
    Emitter<SplitBillState> emit,
  ) async {
    try {
      usecase.deleteBill(state.model?.id ?? '');
      emit(state.copyWith(status: SplitBillStatus.finish));
    } catch (e) {
      emit(state.copyWith(status: SplitBillStatus.failed, errorMessage: '$e'));
    }
  }

  Future<void> _addUserToSplitBill(
    AddUserToSplitBill event,
    Emitter<SplitBillState> emit,
  ) async {
    final currentModel = state.model;
    if (currentModel != null) {
      final newUser = UserModel(id: Uuid().v4(), name: event.name, image: '');
      final updatedUsers = List<UserModel>.from(currentModel.users)
        ..add(newUser);
      final updatedModel = SplitBillModel(
        id: currentModel.id,
        users: updatedUsers,
        billModel: currentModel.billModel,
      );
      emit(state.copyWith(model: updatedModel));
    }
  }

  Future<void> _updateUserName(
    UpdateUserName event,
    Emitter<SplitBillState> emit,
  ) async {
    final currentModel = state.model;
    if (currentModel != null) {
      final updatedUsers = currentModel.users.map((user) {
        if (user.id == event.userId) {
          return UserModel(id: user.id, name: event.name, image: user.image);
        }
        return user;
      }).toList();
      final updatedModel = SplitBillModel(
        id: currentModel.id,
        users: updatedUsers,
        billModel: currentModel.billModel,
      );
      emit(state.copyWith(model: updatedModel));
    }
  }

  Future<void> _updateSelectedUser(
    UpdateSelectedUser event,
    Emitter<SplitBillState> emit,
  ) async {
    final currentModel = state.model;
    if (currentModel != null) {
      final updatedUser = currentModel.users.firstWhere(
        (e) => e.id == event.userId,
      );

      emit(state.copyWith(selectedUser: updatedUser));
    }
  }

  Future<void> _assignUserToBillItem(
    AssignUserToBillItem event,
    Emitter<SplitBillState> emit,
  ) async {
    final currentModel = state.model;
    if (currentModel != null && state.selectedUser != null) {
      final items = currentModel.billModel.items ?? [];
      if (event.itemIndex < items.length) {
        final item = items[event.itemIndex];
        List<String> updatedUserIds;
        if (item.userIds.contains(event.userId)) {
          // Remove user
          updatedUserIds = List<String>.from(item.userIds)
            ..remove(event.userId);
        } else {
          // Add user
          updatedUserIds = List<String>.from(item.userIds)..add(event.userId);
        }
        final updatedItem = BillElementModel(
          name: item.name,
          quantity: item.quantity,
          price: item.price,
          userIds: updatedUserIds,
        );
        final updatedItems = List<BillElementModel>.from(items)
          ..[event.itemIndex] = updatedItem;
        final updatedBillModel = BillModel(
          items: updatedItems,
          subtotal: currentModel.billModel.subtotal,
          service: currentModel.billModel.service,
          tax: currentModel.billModel.tax,
          discount: currentModel.billModel.discount,
          total: currentModel.billModel.total,
          billName: currentModel.billModel.billName,
        );
        final updatedModel = SplitBillModel(
          id: currentModel.id,
          users: currentModel.users,
          billModel: updatedBillModel,
        );
        emit(state.copyWith(model: updatedModel));
      }
    }
  }

  Future<void> _calculateSummary(
    CalculateSummary event,
    Emitter<SplitBillState> emit,
  ) async {
    try {
      final model = state.model;
      if (model == null) return;
      final users = model.users;
      final items = model.billModel.items ?? [];
      final service = model.billModel.service;
      final tax = model.billModel.tax;
      final discount = model.billModel.discount;
      final total = model.billModel.total;

      // Calculate each user's share of items
      final Map<String, num> userToItemTotal = {for (var u in users) u.id: 0};
      final Map<String, List<String>> userToItemNames = {
        for (var u in users) u.id: [],
      };
      for (final item in items) {
        if (item.userIds.isEmpty) continue;
        final perUser = (item.price * item.quantity) / item.userIds.length;
        for (final uid in item.userIds) {
          userToItemTotal[uid] = (userToItemTotal[uid] ?? 0) + perUser;
          userToItemNames[uid] = [...userToItemNames[uid] ?? [], item.name];
        }
      }

      // Calculate each user's share of service, tax, discount proportionally
      final itemTotalSum = userToItemTotal.values.fold<num>(0, (a, b) => a + b);
      Map<String, num> userToTotal = {};
      for (final u in users) {
        final itemTotal = userToItemTotal[u.id] ?? 0;
        final ratio = itemTotalSum > 0 ? itemTotal / itemTotalSum : 0;
        final userService = service * ratio;
        final userTax = tax * ratio;
        final userDiscount = discount * ratio;
        final userTotal = itemTotal + userService + userTax - userDiscount;
        userToTotal[u.id] = userTotal;
      }

      // ensure sum matches total bill
      final sumAll = userToTotal.values.fold<num>(0, (a, b) => a + b);
      final diff = total - sumAll;
      if (users.isNotEmpty && diff.abs() > 0.01) {
        // Add/subtract the diff to the first user
        final firstId = users.first.id;
        userToTotal[firstId] = (userToTotal[firstId] ?? 0) + diff;
      }

      // Map to SummaryModel
      final summaryList = users
          .map(
            (u) => SummaryItemModel(
              userId: u.id,
              totalOwned: userToTotal[u.id] ?? 0,
              items: userToItemNames[u.id] ?? [],
            ),
          )
          .toList();
      final summary = SummaryModel(
        id: '',
        billName: model.billModel.billName,
        userList: users,
        summaryList: summaryList,
      );
      final id = await usecase.createSummary(summary);
      usecase.deleteBill(state.model?.id ?? '');

      emit(state.copyWith(status: SplitBillStatus.finish, id: id));
    } catch (e) {
      emit(state.copyWith(status: SplitBillStatus.failed, errorMessage: '$e'));
    }
  }
}
