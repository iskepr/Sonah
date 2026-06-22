// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplicationModelAdapter extends TypeAdapter<ApplicationModel> {
  @override
  final int typeId = 4;

  @override
  ApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationModel(
      appInfoMap: (fields[0] as Map).cast<String, dynamic>(),
      isFavorite: fields[1] as bool,
      isHidden: fields[2] as bool,
      openCount: fields[3] as int,
      lastOpenTime: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.appInfoMap)
      ..writeByte(1)
      ..write(obj.isFavorite)
      ..writeByte(2)
      ..write(obj.isHidden)
      ..writeByte(3)
      ..write(obj.openCount)
      ..writeByte(4)
      ..write(obj.lastOpenTime)
      ..writeByte(5)
      ..write(obj.usageTimeInMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
