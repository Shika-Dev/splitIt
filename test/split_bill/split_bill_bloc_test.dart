import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Domain/Models/bill_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Presentation/split_bill/bloc/split_bill_bloc.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('SplitBill Bloc Test', () {
    late MockSplitBillUsecase mockSplitBillUseCase;
    late SplitBillBloc bloc;

    setUp(() {
      mockSplitBillUseCase = MockSplitBillUsecase();
      bloc = SplitBillBloc(usecase: mockSplitBillUseCase);
    });

    tearDown(() {
      bloc.close();
    });

    group("InitSplitBill", () {
      test('Initial state is correct', () {
        expect(bloc.state.status, equals(SplitBillStatus.initial));
        expect(bloc.state.id, isEmpty);
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.model, isNull);
        expect(bloc.state.selectedUser, isNull);
      });

      blocTest<SplitBillBloc, SplitBillState>(
        'emit [loading, success] when successfully get the data',
        build: () {
          final model = SplitBillModel(
            id: 'billId',
            users: [UserModel(id: 'me', name: 'User Name', image: 'image')],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          when(
            mockSplitBillUseCase.getBillDetail('billId'),
          ).thenAnswer((_) async => model);
          return bloc;
        },
        act: (bloc) => bloc.add(InitSplitBillPage(id: 'billId')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.status,
            "status",
            SplitBillStatus.loading,
          ),
          isA<SplitBillState>()
              .having((s) => s.status, "status", SplitBillStatus.success)
              .having((s) => s.selectedUser, "selected user", isNotNull)
              .having((s) => s.model, "model", isNotNull)
              .having((s) => s.errorMessage, "error Message", isNull),
        ],
      );

      blocTest<SplitBillBloc, SplitBillState>(
        'emit [loading, failed] when failed get the data',
        build: () {
          when(
            mockSplitBillUseCase.getBillDetail('billId'),
          ).thenThrow(Exception("Bill not found"));
          return bloc;
        },
        act: (bloc) => bloc.add(InitSplitBillPage(id: 'billId')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.status,
            "status",
            SplitBillStatus.loading,
          ),
          isA<SplitBillState>()
              .having((s) => s.status, "status", SplitBillStatus.failed)
              .having(
                (s) => s.errorMessage,
                "error message",
                "Exception: Bill not found",
              ),
        ],
      );
    });

    group("SplitBillDispose", () {
      blocTest<SplitBillBloc, SplitBillState>(
        "emit [finish] when successfully dispose the page",
        build: () {
          final user = UserModel(id: 'me', name: 'User Name', image: 'image');
          final model = SplitBillModel(
            id: 'billId',
            users: [user],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user,
              errorMessage: null,
              id: 'billId',
            ),
          );
          when(
            mockSplitBillUseCase.deleteBill("billId"),
          ).thenAnswer((_) async {});

          return bloc;
        },
        act: (bloc) => bloc.add(SplitBillPageDispose()),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.status,
            "status",
            SplitBillStatus.finish,
          ),
        ],
      );

      blocTest<SplitBillBloc, SplitBillState>(
        "emit [failed] when failed dispose the page",
        build: () {
          final user = UserModel(id: 'me', name: 'User Name', image: 'image');
          final model = SplitBillModel(
            id: 'billId',
            users: [user],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user,
              errorMessage: null,
              id: 'billId',
            ),
          );

          when(
            mockSplitBillUseCase.deleteBill("billId"),
          ).thenThrow(Exception("Failed to delete the bill"));

          return bloc;
        },
        act: (bloc) => bloc.add(SplitBillPageDispose()),
        expect: () => [
          isA<SplitBillState>()
              .having((s) => s.status, "status", SplitBillStatus.failed)
              .having(
                (s) => s.errorMessage,
                "error message",
                "Exception: Failed to delete the bill",
              ),
        ],
      );
    });

    group("AddUserToSplitBill", () {
      blocTest<SplitBillBloc, SplitBillState>(
        'adds a new user to the split bill',
        build: () {
          final user = UserModel(id: 'me', name: 'User Name', image: 'image');
          final model = SplitBillModel(
            id: 'billId',
            users: [user],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user,
              errorMessage: null,
              id: 'billId',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(AddUserToSplitBill(name: 'New User')),
        expect: () => [
          isA<SplitBillState>()
              .having((s) => s.model?.users.length, 'users length', 2)
              .having(
                (s) => s.model?.users.last.name,
                'last user name',
                'New User',
              ),
        ],
      );
    });

    group("UpdateUserName", () {
      blocTest<SplitBillBloc, SplitBillState>(
        'updates the user name in the split bill',
        build: () {
          final user = UserModel(id: 'me', name: 'User Name', image: 'image');
          final model = SplitBillModel(
            id: 'billId',
            users: [user],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user,
              errorMessage: null,
              id: 'billId',
            ),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(UpdateUserName(userId: 'me', name: 'Updated Name')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.model?.users.first.name,
            'user name',
            'Updated Name',
          ),
        ],
      );
    });

    group("UpdateSelectedUser", () {
      blocTest<SplitBillBloc, SplitBillState>(
        'updates the selected user',
        build: () {
          final user1 = UserModel(id: 'me', name: 'User Name', image: 'image');
          final user2 = UserModel(id: 'u2', name: 'User 2', image: 'img2');
          final model = SplitBillModel(
            id: 'billId',
            users: [user1, user2],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user1,
              errorMessage: null,
              id: 'billId',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateSelectedUser(userId: 'u2')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.selectedUser?.id,
            'selected user id',
            'u2',
          ),
        ],
      );
    });

    group("AssignUserToBillItem", () {
      blocTest<SplitBillBloc, SplitBillState>(
        'assigns a user to a bill item (add)',
        build: () {
          final user1 = UserModel(id: 'me', name: 'User Name', image: 'image');
          final user2 = UserModel(id: 'u2', name: 'User 2', image: 'img2');
          final model = SplitBillModel(
            id: 'billId',
            users: [user1, user2],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user1,
              errorMessage: null,
              id: 'billId',
            ),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AssignUserToBillItem(itemIndex: 0, userId: 'u2')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.model?.billModel.items?[0].userIds,
            'userIds',
            containsAll(['me', 'u2']),
          ),
        ],
      );

      blocTest<SplitBillBloc, SplitBillState>(
        'removes a user from a bill item (remove)',
        build: () {
          final user1 = UserModel(id: 'me', name: 'User Name', image: 'image');
          final user2 = UserModel(id: 'u2', name: 'User 2', image: 'img2');
          final model = SplitBillModel(
            id: 'billId',
            users: [user1, user2],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me", "u2"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user1,
              errorMessage: null,
              id: 'billId',
            ),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AssignUserToBillItem(itemIndex: 0, userId: 'u2')),
        expect: () => [
          isA<SplitBillState>().having(
            (s) => s.model?.billModel.items?[0].userIds,
            'userIds',
            ['me'],
          ),
        ],
      );
    });

    group("CalculateSummary", () {
      blocTest<SplitBillBloc, SplitBillState>(
        'emits [finish] and calls createSummary and deleteBill',
        build: () {
          final user1 = UserModel(id: 'me', name: 'User Name', image: 'image');
          final user2 = UserModel(id: 'u2', name: 'User 2', image: 'img2');
          final model = SplitBillModel(
            id: 'billId',
            users: [user1, user2],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me", "u2"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user1,
              errorMessage: null,
              id: 'billId',
            ),
          );
          when(
            mockSplitBillUseCase.createSummary(any),
          ).thenAnswer((_) async => 'summaryId');
          when(
            mockSplitBillUseCase.deleteBill('billId'),
          ).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(CalculateSummary()),
        expect: () => [
          isA<SplitBillState>()
              .having((s) => s.status, 'status', SplitBillStatus.finish)
              .having((s) => s.id, 'id', 'summaryId'),
        ],
        verify: (_) {
          verify(mockSplitBillUseCase.createSummary(any)).called(1);
          verify(mockSplitBillUseCase.deleteBill('billId')).called(1);
        },
      );

      blocTest<SplitBillBloc, SplitBillState>(
        'emits [failed] when createSummary throws',
        build: () {
          final user1 = UserModel(id: 'me', name: 'User Name', image: 'image');
          final model = SplitBillModel(
            id: 'billId',
            users: [user1],
            billModel: BillModel(
              items: [
                BillElementModel(
                  name: "Rice",
                  quantity: 1,
                  price: 10,
                  userIds: ["me"],
                ),
              ],
              subtotal: 10,
              service: 0,
              tax: 0,
              discount: 0,
              total: 10,
              billName: "Rice Shop",
              currency: "\$",
              dateIssued: "January 1, 2021",
            ),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: SplitBillStatus.success,
              model: model,
              selectedUser: user1,
              errorMessage: null,
              id: 'billId',
            ),
          );
          when(
            mockSplitBillUseCase.createSummary(any),
          ).thenThrow(Exception('Failed to create summary'));
          return bloc;
        },
        act: (bloc) => bloc.add(CalculateSummary()),
        expect: () => [
          isA<SplitBillState>()
              .having((s) => s.status, 'status', SplitBillStatus.failed)
              .having(
                (s) => s.errorMessage,
                'error message',
                contains('Failed to create summary'),
              ),
        ],
      );
    });
  });
}
