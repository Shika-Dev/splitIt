import 'package:flutter_test/flutter_test.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Data/Mapper/mapper.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';

void main() {
  group('Mapper Unit Test', () {
    test('toBillItemModel success', () {
      final response = DeepseekResponse(
        items: [BillItemResponse(name: "item 1", quantity: 1, price: 10)],
        subtotal: 10,
        total: 10,
        tax: 0,
        service: 0,
        discount: 0,
        billName: "Bill Name",
        currency: '\%',
        dateIssued: "00/00/0000",
      );
      final result = Mapper.toBillItemModel(response);

      expect(result.billName, response.billName);
      expect(result.currency, response.currency);
      expect(result.dateIssued, response.dateIssued);
      expect(result.total, response.total);
      expect(result.subtotal, response.subtotal);
      expect(result.tax, response.tax);
      expect(result.service, response.service);
      expect(result.discount, response.discount);
      expect(result.items?[0].name, response.items?[0].name);
      expect(result.items?[0].price, response.items?[0].price);
      expect(result.items?[0].quantity, response.items?[0].quantity);
    });

    test('toBillItemModel success', () {
      final response = DeepseekResponse(
        items: [BillItemResponse(name: "item 1", quantity: 1, price: 10)],
        subtotal: 10,
        total: 10,
        tax: 0,
        service: 0,
        discount: 0,
        billName: "Bill Name",
        currency: '\%',
        dateIssued: "00/00/0000",
      );
      final result = Mapper.toBillItemModel(response);

      expect(result.billName, response.billName);
      expect(result.currency, response.currency);
      expect(result.dateIssued, response.dateIssued);
      expect(result.total, response.total);
      expect(result.subtotal, response.subtotal);
      expect(result.tax, response.tax);
      expect(result.service, response.service);
      expect(result.discount, response.discount);
      expect(result.items?[0].name, response.items?[0].name);
      expect(result.items?[0].price, response.items?[0].price);
      expect(result.items?[0].quantity, response.items?[0].quantity);
    });

    test('toSplitBillEntity success', () {
      final billItemModel = BillItemModel(
        items: [BillItem(name: 'item', quantity: 2, price: 100)],
        subtotal: 100,
        service: 10,
        tax: 5,
        discount: 0,
        total: 115,
        billName: 'Test Bill',
        currency: 'USD',
        dateIssued: '2024-01-01',
      );
      final entity = Mapper.toSplitBillEntity(billItemModel);
      expect(entity.billEntity.billName, billItemModel.billName);
      expect(entity.billEntity.items[0].name, billItemModel.items![0].name);
      expect(
        entity.billEntity.items[0].quantity,
        billItemModel.items![0].quantity,
      );
      expect(entity.billEntity.items[0].price, billItemModel.items![0].price);
      expect(entity.billEntity.subtotal, billItemModel.subtotal);
      expect(entity.billEntity.total, billItemModel.total);
      expect(entity.listUser[0].name, 'You');
    });

    test('toSplitBillModel success', () {
      final splitBillEntity = SplitBillEntity(
        id: 'split-id',
        listUser: [UserEntity(id: 'u1', name: 'User 1', image: 'img1')],
        billEntity: BillEntity(
          items: [
            BillItemEntity(
              name: 'item',
              quantity: 2,
              price: 100,
              userIds: ['u1'],
            ),
          ],
          subtotal: 100,
          service: 10,
          tax: 5,
          discount: 0,
          total: 115,
          billName: 'Test Bill',
          currency: 'USD',
          dateIssued: '2024-01-01',
        ),
      );
      final model = Mapper.toSplitBillModel(splitBillEntity);
      expect(model.id, splitBillEntity.id);
      expect(model.users[0].id, splitBillEntity.listUser[0].id);
      expect(model.billModel.billName, splitBillEntity.billEntity.billName);
      expect(
        model.billModel.items![0].name,
        splitBillEntity.billEntity.items[0].name,
      );
      expect(
        model.billModel.items![0].userIds,
        splitBillEntity.billEntity.items[0].userIds,
      );
    });

    test('toSummaryEntity success', () {
      final summaryModel = SummaryModel(
        id: 'sum-id',
        billName: 'Summary Bill',
        userList: [UserModel(id: 'u1', name: 'User 1', image: 'img1')],
        summaryList: [
          SummaryItemModel(userId: 'u1', totalOwned: 50, items: ['item1']),
        ],
        currency: 'USD',
        dateIssued: '2024-01-01',
      );
      final entity = Mapper.toSummaryEntity(summaryModel);
      expect(entity.billName, summaryModel.billName);
      expect(entity.userList[0].id, summaryModel.userList[0].id);
      expect(entity.summaryList[0].userId, summaryModel.summaryList[0].userId);
      expect(
        entity.summaryList[0].totalOwned,
        summaryModel.summaryList[0].totalOwned,
      );
      expect(entity.summaryList[0].items, summaryModel.summaryList[0].items);
      expect(entity.currency, summaryModel.currency);
    });

    test('toSummaryModel success', () {
      final summaryEntity = SummaryEntity(
        id: 'sum-id',
        billName: 'Summary Bill',
        userList: [UserEntity(id: 'u1', name: 'User 1', image: 'img1')],
        summaryList: [
          SummaryItemEntity(userId: 'u1', totalOwned: 50, items: ['item1']),
        ],
        currency: 'USD',
        dateIssued: '2024-01-01',
      );
      final model = Mapper.toSummaryModel(summaryEntity);
      expect(model.billName, summaryEntity.billName);
      expect(model.userList[0].id, summaryEntity.userList[0].id);
      expect(model.summaryList[0].userId, summaryEntity.summaryList[0].userId);
      expect(
        model.summaryList[0].totalOwned,
        summaryEntity.summaryList[0].totalOwned,
      );
      expect(model.summaryList[0].items, summaryEntity.summaryList[0].items);
      expect(model.currency, summaryEntity.currency);
    });

    test('toListOfSummaryModel success', () {
      final summaryEntities = [
        SummaryEntity(
          id: 'sum-id',
          billName: 'Summary Bill',
          userList: [UserEntity(id: 'u1', name: 'User 1', image: 'img1')],
          summaryList: [
            SummaryItemEntity(userId: 'u1', totalOwned: 50, items: ['item1']),
          ],
          currency: 'USD',
          dateIssued: '2024-01-01',
        ),
      ];
      final models = Mapper.toListOfSummaryModel(summaryEntities);
      expect(models.length, 1);
      expect(models[0].billName, summaryEntities[0].billName);
      expect(models[0].userList[0].id, summaryEntities[0].userList[0].id);
      expect(
        models[0].summaryList[0].userId,
        summaryEntities[0].summaryList[0].userId,
      );
    });
  });
}
