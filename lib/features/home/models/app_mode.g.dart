// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppModeAdapter extends TypeAdapter<AppMode> {
  @override
  final int typeId = 2;

  @override
  AppMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppMode.normal;
      case 1:
        return AppMode.focus;
      case 2:
        return AppMode.prayer;
      case 3:
        return AppMode.sleep;
      case 4:
        return AppMode.search;
      default:
        return AppMode.normal;
    }
  }

  @override
  void write(BinaryWriter writer, AppMode obj) {
    switch (obj) {
      case AppMode.normal:
        writer.writeByte(0);
        break;
      case AppMode.focus:
        writer.writeByte(1);
        break;
      case AppMode.prayer:
        writer.writeByte(2);
        break;
      case AppMode.sleep:
        writer.writeByte(3);
        break;
      case AppMode.search:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
