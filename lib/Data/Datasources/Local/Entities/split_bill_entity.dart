import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';

part 'split_bill_entity.g.dart';

@HiveType(typeId: 1)
class SplitBillEntity {
  SplitBillEntity({
    required this.id,
    required this.listUser,
    required this.billEntity,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  List<UserEntity> listUser;

  @HiveField(2)
  BillEntity billEntity;
}
