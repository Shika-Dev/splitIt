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
      );
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
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
      );
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }

  static List<SummaryModel> toListOfSummaryModel(List<SummaryEntity> entities) {
    try {
      return entities.map((entity) {
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
        );
      }).toList();
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }
}
