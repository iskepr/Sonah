import "package:flutter/material.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:usage_stats/usage_stats.dart" hide AppInfo;

import "../../../constant.dart";
import "../../../core/helpers/hive_helper.dart";
import "../models/application_model.dart";

class SystemAppsRepository {
  List<ApplicationModel> getCachedApps() {
    return HiveHelper.getListData<ApplicationModel>(kBoxSystemApps);
  }

  void cacheApps(List<ApplicationModel> apps) {
    HiveHelper.saveListData<ApplicationModel>(kBoxSystemApps, apps);
  }

  Future<List<ApplicationModel>> fetchDeviceApps(
    List<ApplicationModel> cachedApps,
  ) async {
    final List<AppInfo> appsInfo = await FlutterDeviceApps.listApps(
      includeSystem: true,
      includeIcons: true,
      onlyLaunchable: true,
    );

    if (appsInfo.isEmpty) return cachedApps;

    final updatedList = appsInfo.map((info) {
      final oldApp = cachedApps.firstWhere(
        (element) => element.appInfo.packageName == info.packageName,
        orElse: () => ApplicationModel(appInfoMap: appInfoToMap(info)),
      );
      return oldApp.copyWith(appInfo: info);
    }).toList();

    return sortApps(updatedList);
  }

  Future<Map<String, Duration>> fetchTodayUsageMap() async {
    final Map<String, Duration> usageMap = {};
    try {
      final bool? isPermissionGranted = await UsageStats.checkUsagePermission();
      if (isPermissionGranted != true) return usageMap;

      final DateTime now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month, now.day).toUtc();
      final DateTime endDate = now.toUtc();

      final Map<String, UsageInfo> infoMap =
          await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

      for (var entry in infoMap.entries) {
        if (entry.value.packageName != null &&
            entry.value.totalTimeInForeground != null) {
          usageMap[entry.key] = Duration(
            milliseconds: int.parse(entry.value.totalTimeInForeground!),
          );
        }
      }
    } catch (e) {
      debugPrint("فشل جلب أوقات الاستخدام: $e");
    }
    return usageMap;
  }

  /// جلب متوسط الاستخدام اليومي لآخر 7 أيام
  Future<Map<String, Duration>> getDailyAverageStats() async {
    final Map<String, Duration> averageMap = {};
    try {
      final DateTime now = DateTime.now();
      final DateTime startDate = now.subtract(const Duration(days: 7)).toUtc();
      final DateTime endDate = now.toUtc();

      final Map<String, UsageInfo> infoMap =
          await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

      for (var entry in infoMap.entries) {
        if (entry.value.totalTimeInForeground != null) {
          final totalMillis = int.parse(entry.value.totalTimeInForeground!);
          averageMap[entry.key] = Duration(
            milliseconds: (totalMillis / 7).round(),
          );
        }
      }
    } catch (e) {
      debugPrint("فشل جلب متوسط الاستخدام: $e");
    }
    return averageMap;
  }

  List<ApplicationModel> sortApps(List<ApplicationModel> list) {
    return list..sort(
      (a, b) => (a.appInfo.appName ?? "").toLowerCase().compareTo(
        (b.appInfo.appName ?? "").toLowerCase(),
      ),
    );
  }
}
