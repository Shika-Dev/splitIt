// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_item_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillItemEntityAdapter extends TypeAdapter<BillItemEntity> {
  @override
  final int typeId = 3;

  @override
  BillItemEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillItemEntity(
      name: fields[0] as String,
      quantity: fields[1] as num,
      price: fields[2] as num,
      userIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BillItemEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.userIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillItemEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
