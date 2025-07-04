import 'package:hive/hive.dart';

part 'bill_item_entity.g.dart';

@HiveType(typeId: 3)
class BillItemEntity {
  BillItemEntity({
    required this.name,
    required this.quantity,
    required this.price,
    required this.userIds,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  num quantity;

  @HiveField(2)
  num price;

  @HiveField(3)
  List<String> userIds;
}
