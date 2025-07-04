// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_item_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryItemEntityAdapter extends TypeAdapter<SummaryItemEntity> {
  @override
  final int typeId = 6;

  @override
  SummaryItemEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummaryItemEntity(
      userId: fields[0] as String,
      totalOwned: fields[2] as num,
      items: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SummaryItemEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.totalOwned)
      ..writeByte(3)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryItemEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
