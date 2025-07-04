// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryEntityAdapter extends TypeAdapter<SummaryEntity> {
  @override
  final int typeId = 5;

  @override
  SummaryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummaryEntity(
      billName: fields[0] as String,
      userList: (fields[2] as List).cast<UserEntity>(),
      summaryList: (fields[3] as List).cast<SummaryItemEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SummaryEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.billName)
      ..writeByte(2)
      ..write(obj.userList)
      ..writeByte(3)
      ..write(obj.summaryList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
