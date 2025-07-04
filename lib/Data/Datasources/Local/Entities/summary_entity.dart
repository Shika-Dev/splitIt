import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';

part 'summary_entity.g.dart';

@HiveType(typeId: 5)
class SummaryEntity {
  SummaryEntity({
    required this.id,
    required this.billName,
    required this.userList,
    required this.summaryList,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String billName;

  @HiveField(2)
  List<UserEntity> userList;

  @HiveField(3)
  List<SummaryItemEntity> summaryList;
}
