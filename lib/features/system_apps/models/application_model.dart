// inside application_model.dart

import "package:flutter_device_apps/flutter_device_apps.dart";

class ApplicationModel {
  final AppInfo appInfo;
  final bool isFavorite;
  final bool isHidden;

  ApplicationModel({
    required this.appInfo,
    this.isFavorite = false,
    this.isHidden = false,
  });

  // تحويل الموديل لـ Map عشان يخزن في Hive
  Map<String, dynamic> toMap() {
    return {
      "isFavorite": isFavorite,
      "isHidden": isHidden,
      "appInfo": _appInfoToMap(appInfo),
    };
  }

  // القراءة من الـ Map اللي راجع من Hive
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      isFavorite: map["isFavorite"] ?? false,
      isHidden: map["isHidden"] ?? false,
      appInfo: AppInfo.fromMap(Map<String, Object?>.from(map["appInfo"] ?? {})),
    );
  }

  // دالة مساعدة لأن باكدج flutter_device_apps مش بتوفر toMap للـ AppInfo
  Map<String, dynamic> _appInfoToMap(AppInfo info) {
    return {
      "packageName": info.packageName,
      "appName": info.appName,
      "versionName": info.versionName,
      "versionCode": info.versionCode,
      "uid": info.uid,
      "apkPath": info.apkPath,
      "apkSizeBytes": info.apkSizeBytes,
      "dataPath": info.dataPath,
      "isOnExternalStorage": info.isOnExternalStorage,
      "firstInstallTime": info.firstInstallTime?.millisecondsSinceEpoch,
      "lastUpdateTime": info.lastUpdateTime?.millisecondsSinceEpoch,
      "isSystem": info.isSystem,
      "iconBytes": info.iconBytes,
      "category": info.category,
      "targetSdkVersion": info.targetSdkVersion,
      "minSdkVersion": info.minSdkVersion,
      "enabled": info.enabled,
      "processName": info.processName,
      "installLocation": info.installLocation,
    };
  }

  ApplicationModel copyWith({
    AppInfo? appInfo,
    bool? isFavorite,
    bool? isHidden,
  }) {
    return ApplicationModel(
      appInfo: appInfo ?? this.appInfo,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
