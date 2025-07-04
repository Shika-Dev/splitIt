// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillEntityAdapter extends TypeAdapter<BillEntity> {
  @override
  final int typeId = 4;

  @override
  BillEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillEntity(
      items: (fields[0] as List).cast<BillItemEntity>(),
      subtotal: fields[1] as num,
      service: fields[2] as num,
      tax: fields[3] as num,
      discount: fields[4] as num,
      total: fields[5] as num,
      billName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BillEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.subtotal)
      ..writeByte(2)
      ..write(obj.service)
      ..writeByte(3)
      ..write(obj.tax)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.billName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
