import "package:flutter_device_apps/flutter_device_apps.dart";

class ApplicationModel {
  final AppInfo appInfo;
  final bool isFavorite;
  final bool isHidden;
  final int openCount;
  final DateTime? lastOpenTime;

  ApplicationModel({
    required this.appInfo,
    this.isFavorite = false,
    this.isHidden = false,
    this.openCount = 0,
    this.lastOpenTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "isFavorite": isFavorite,
      "isHidden": isHidden,
      "openCount": openCount,
      "lastOpenTime": lastOpenTime?.millisecondsSinceEpoch,
      "appInfo": _appInfoToMap(appInfo),
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      isFavorite: map["isFavorite"] ?? false,
      isHidden: map["isHidden"] ?? false,
      openCount: map["openCount"] ?? 0,
      lastOpenTime: map["lastOpenTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(map["lastOpenTime"])
          : null,
      appInfo: AppInfo.fromMap(Map<String, Object?>.from(map["appInfo"] ?? {})),
    );
  }

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
    int? openCount,
    DateTime? lastOpenTime,
  }) {
    return ApplicationModel(
      appInfo: appInfo ?? this.appInfo,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      openCount: openCount ?? this.openCount,
      lastOpenTime: lastOpenTime ?? this.lastOpenTime,
    );
  }
}
