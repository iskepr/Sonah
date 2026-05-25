import "dart:typed_data";

import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:hive/hive.dart";

class ApplicationModel {
  final String appName;
  final String packageName;
  final Uint8List? iconBytes;
  final bool isFavorite;

  ApplicationModel({
    required this.appName,
    required this.packageName,
    this.iconBytes,
    this.isFavorite = false,
  });

  factory ApplicationModel.fromAppInfo(
    AppInfo info, {
    bool isFavorite = false,
  }) {
    return ApplicationModel(
      appName: info.appName ?? "",
      packageName: info.packageName ?? "",
      iconBytes: info.iconBytes,
      isFavorite: isFavorite,
    );
  }

  // copyWith عشان تعديل الـ isFavorite بسهولة
  ApplicationModel copyWith({bool? isFavorite}) {
    return ApplicationModel(
      appName: appName,
      packageName: packageName,
      iconBytes: iconBytes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// الـ Adapter اليدوي عشان نوفر مساحة التنزيل والباقة
class ApplicationModelAdapter extends TypeAdapter<ApplicationModel> {
  @override
  final int typeId = 1; // رقم فريد للـ Adapter ده جوه الـ Hive

  @override
  ApplicationModel read(BinaryReader reader) {
    // الترتيب هنا مهم جداً ولازم يطابق الترتيب في الـ write
    return ApplicationModel(
      appName: reader.readString(),
      packageName: reader.readString(),
      iconBytes: reader.readByteList(),
      isFavorite: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationModel obj) {
    writer.writeString(obj.appName);
    writer.writeString(obj.packageName);
    writer.writeByteList(obj.iconBytes ?? Uint8List(0));
    writer.writeBool(obj.isFavorite);
  }
}
