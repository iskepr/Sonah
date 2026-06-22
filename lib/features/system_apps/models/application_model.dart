import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:hive_flutter/hive_flutter.dart";

part "application_model.g.dart";

@HiveType(typeId: 4)
class ApplicationModel extends HiveObject {
  @HiveField(0)
  final Map<String, dynamic> appInfoMap;

  @HiveField(1)
  final bool isFavorite;

  @HiveField(2)
  final bool isHidden;

  @HiveField(3)
  final int openCount;

  @HiveField(4)
  final DateTime? lastOpenTime;

  @HiveField(5)
  final int usageTimeInMillis;

  @HiveField(7)
  final int usageTimeLimitInMillis;

  final Duration usageTime;
  final Duration usageTimeLimit;

  ApplicationModel({
    required this.appInfoMap,
    this.isFavorite = false,
    this.isHidden = false,
    this.openCount = 0,
    this.lastOpenTime,
    Duration usageTime = Duration.zero,
    Duration usageTimeLimit = Duration.zero,
  }) : usageTime = usageTime,
       usageTimeInMillis = usageTime.inMilliseconds,
       usageTimeLimit = usageTimeLimit,
       usageTimeLimitInMillis = usageTimeLimit.inMilliseconds;

  Duration get currentUsageTime => Duration(milliseconds: usageTimeInMillis);
  Duration get currentUsageTimeLimit =>
      Duration(milliseconds: usageTimeLimitInMillis);

  AppInfo get appInfo => AppInfo.fromMap(Map<String, Object?>.from(appInfoMap));

  Map<String, dynamic> toMap() {
    return {
      "isFavorite": isFavorite,
      "isHidden": isHidden,
      "openCount": openCount,
      "lastOpenTime": lastOpenTime?.millisecondsSinceEpoch,
      "appInfo": appInfoMap,
      "usageTime": usageTimeInMillis,
    };
  }

  ApplicationModel copyWith({
    AppInfo? appInfo,
    bool? isFavorite,
    bool? isHidden,
    int? openCount,
    DateTime? lastOpenTime,
    Duration? usageTime,
    Duration? usageTimeLimit,
  }) {
    return ApplicationModel(
      appInfoMap: appInfo != null ? appInfoToMap(appInfo) : appInfoMap,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      openCount: openCount ?? this.openCount,
      lastOpenTime: lastOpenTime ?? this.lastOpenTime,
      usageTime: usageTime ?? currentUsageTime,
      usageTimeLimit: usageTimeLimit ?? currentUsageTimeLimit,
    );
  }
}

Map<String, dynamic> appInfoToMap(AppInfo info) {
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
