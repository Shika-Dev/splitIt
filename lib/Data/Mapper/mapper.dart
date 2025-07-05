import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Models/bill_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';
import 'package:uuid/uuid.dart';

class Mapper {
  static BillItemModel toBillItemModel(DeepseekResponse response) {
    try {
      // Validate that we have essential bill data
      if (response.items == null || response.items!.isEmpty) {
        throw Exception('No bill items found in the response');
      }

      if (response.total == null || response.total! <= 0) {
        throw Exception('Invalid or missing total amount');
      }

      // Validate that items have meaningful data
      for (var item in response.items!) {
        if (item.name == null || item.name!.trim().isEmpty) {
          throw Exception('Invalid item name found');
        }
        if (item.price == null || item.price! <= 0) {
          throw Exception('Invalid item price found');
        }
      }

      return BillItemModel(
        items:
            response.items
                ?.map(
                  (e) => BillItem(
                    name: e.name ?? '',
                    quantity: e.quantity ?? 0,
                    price: e.price ?? 0,
                  ),
                )
                .toList() ??
            [],
        subtotal: response.subtotal ?? 0,
        service: response.service ?? 0,
        tax: response.tax ?? 0,
        discount: response.discount ?? 0,
        total: response.total ?? 0,
        billName: response.billName ?? '',
        currency: response.currency ?? '',
        dateIssued: response.dateIssued ?? '',
      );
    } catch (e) {
      throw Exception('Invalid bill data: ${e.toString()}');
    }
  }

  static SplitBillEntity toSplitBillEntity(BillItemModel model) {
    final currentUser = UserEntity(
      id: 'me',
      name: 'You',
      image: 'your_image_url_or_path',
    );
    return SplitBillEntity(
      id: Uuid().v4(),
      listUser: [currentUser],
      billEntity: BillEntity(
        items:
            model.items
                ?.map(
                  (e) => BillItemEntity(
                    name: e.name,
                    quantity: e.quantity,
                    price: e.price,
                    userIds: [],
                  ),
                )
                .toList() ??
            [],
        subtotal: model.subtotal,
        service: model.service,
        tax: model.tax,
        discount: model.discount,
        total: model.total,
        billName: model.billName,
        currency: model.currency,
        dateIssued: model.dateIssued,
      ),
    );
  }

  static toSplitBillModel(SplitBillEntity entity) {
    return SplitBillModel(
      id: entity.id,
      users: entity.listUser
          .map((e) => UserModel(id: e.id, name: e.name, image: e.image))
          .toList(),
      billModel: BillModel(
        items: entity.billEntity.items
            .map(
              (e) => BillElementModel(
                name: e.name,
                quantity: e.quantity,
                price: e.price,
                userIds: e.userIds,
              ),
            )
            .toList(),
        subtotal: entity.billEntity.subtotal,
        service: entity.billEntity.service,
        tax: entity.billEntity.tax,
        discount: entity.billEntity.discount,
        total: entity.billEntity.total,
        billName: entity.billEntity.billName,
        currency: entity.billEntity.currency,
        dateIssued: entity.billEntity.dateIssued,
      ),
    );
  }

  static SummaryEntity toSummaryEntity(SummaryModel model) {
    try {
      return SummaryEntity(
        id: Uuid().v4(),
        billName: model.billName,
        userList: model.userList
            .map((e) => UserEntity(name: e.name, image: e.image, id: e.id))
            .toList(),
        summaryList: model.summaryList
            .map(
              (e) => SummaryItemEntity(
                userId: e.userId,
                totalOwned: e.totalOwned,
                items: e.items,
              ),
            )
            .toList(),
        currency: model.currency,
        dateIssued: model.dateIssued,
      );
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }

  static SummaryModel toSummaryModel(SummaryEntity entity) {
    try {
      return SummaryModel(
        id: entity.id,
        billName: entity.billName,
        userList: entity.userList
            .map((e) => UserModel(id: e.id, name: e.name, image: e.image))
            .toList(),
        summaryList: entity.summaryList
            .map(
              (e) => SummaryItemModel(
                userId: e.userId,
                totalOwned: e.totalOwned,
                items: e.items,
              ),
            )
            .toList(),
        currency: entity.currency,
        dateIssued: entity.dateIssued,
      );
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }

  static List<SummaryModel> toListOfSummaryModel(List<SummaryEntity> entities) {
    try {
      return entities.map((entity) => toSummaryModel(entity)).toList();
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }
}
