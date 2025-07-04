// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_bill_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitBillEntityAdapter extends TypeAdapter<SplitBillEntity> {
  @override
  final int typeId = 1;

  @override
  SplitBillEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitBillEntity(
      id: fields[0] as String,
      listUser: (fields[1] as List).cast<UserEntity>(),
      billEntity: fields[2] as BillEntity,
    );
  }

  @override
  void write(BinaryWriter writer, SplitBillEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listUser)
      ..writeByte(2)
      ..write(obj.billEntity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitBillEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
