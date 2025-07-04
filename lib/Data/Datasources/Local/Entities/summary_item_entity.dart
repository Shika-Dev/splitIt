import 'package:hive/hive.dart';

part 'summary_item_entity.g.dart';

@HiveType(typeId: 6)
class SummaryItemEntity {
  SummaryItemEntity({
    required this.userId,
    required this.totalOwned,
    required this.items,
  });

  @HiveField(0)
  String userId;

  @HiveField(2)
  num totalOwned;

  @HiveField(3)
  List<String> items;
}
