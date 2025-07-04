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
      id: fields[0] as String,
      billName: fields[1] as String,
      userList: (fields[2] as List).cast<UserEntity>(),
      summaryList: (fields[3] as List).cast<SummaryItemEntity>(),
      currency: fields[4] as String,
      dateIssued: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SummaryEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.billName)
      ..writeByte(2)
      ..write(obj.userList)
      ..writeByte(3)
      ..write(obj.summaryList)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.dateIssued);
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
