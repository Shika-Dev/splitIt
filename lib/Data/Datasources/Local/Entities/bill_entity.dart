import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';

part 'bill_entity.g.dart';

@HiveType(typeId: 4)
class BillEntity {
  BillEntity({
    required this.items,
    required this.subtotal,
    required this.service,
    required this.tax,
    required this.discount,
    required this.total,
    required this.billName,
  });

  @HiveField(0)
  List<BillItemEntity> items;

  @HiveField(1)
  num subtotal;

  @HiveField(2)
  num service;

  @HiveField(3)
  num tax;

  @HiveField(4)
  num discount;

  @HiveField(5)
  num total;

  @HiveField(6)
  String billName;
}
