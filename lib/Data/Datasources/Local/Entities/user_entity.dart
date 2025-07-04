import 'package:hive/hive.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 2)
class UserEntity {
  UserEntity({required this.name, required this.image, required this.id});

  @HiveField(0)
  String name;

  @HiveField(1)
  String image;

  @HiveField(2)
  String id;
}
