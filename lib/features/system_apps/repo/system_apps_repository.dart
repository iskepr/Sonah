import "package:flutter/material.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:usage_stats/usage_stats.dart" hide AppInfo;

import "../../../constant.dart";
import "../../../core/extensions/date_time_extensions.dart";
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
      final DateTime startDate = DateTime(now.year, now.month, now.day);

      final List<EventUsageInfo> events = await UsageStats.queryEvents(
        startDate,
        now,
      );

      final Map<String, int> lastResumeTimes = {};
      final Map<String, int> totalTimeInForeground = {};

      for (var event in events) {
        final String? pkg = event.packageName;
        final String? eventType = event.eventType;
        final String? timeStampStr = event.timeStamp;

        if (pkg == null || eventType == null || timeStampStr == null) continue;

        final int timestamp = int.tryParse(timeStampStr) ?? 0;
        if (timestamp == 0) continue;

        // 1 = ACTIVITY_RESUMED (التطبيق اتفتح وبقى على الشاشة)
        // 2 = ACTIVITY_PAUSED (التطبيق نزل في الخلفية أو اتقفل)

        if (eventType == "1") {
          lastResumeTimes[pkg] = timestamp;
        } else if (eventType == "2") {
          if (lastResumeTimes.containsKey(pkg)) {
            final int resumeTime = lastResumeTimes[pkg]!;
            final int duration = timestamp - resumeTime;

            if (duration > 0) {
              totalTimeInForeground[pkg] =
                  (totalTimeInForeground[pkg] ?? 0) + duration;
            }
            lastResumeTimes.remove(pkg);
          }
        }
      }

      // لو في تطبيق إنت فاتحه حالاً ومتقفلش لسه (مفيش Event 2 نزل ليه)
      final int nowTimestamp = now.millisecondsSinceEpoch;
      lastResumeTimes.forEach((pkg, resumeTime) {
        final int duration = nowTimestamp - resumeTime;
        if (duration > 0) {
          totalTimeInForeground[pkg] =
              (totalTimeInForeground[pkg] ?? 0) + duration;
        }
      });

      // تحويل الملي ثواني لـ Duration زي ما إنت عايز
      totalTimeInForeground.forEach((pkg, timeInMs) {
        usageMap[pkg] = Duration(milliseconds: timeInMs);
      });
    } catch (e) {
      debugPrint("فشل جلب أوقات الاستخدام بدقة: $e");
    }
    return usageMap;
  }

  /// جلب متوسط الاستخدام اليومي لآخر 7 أيام
  Future<Map<String, Duration>> getDailyAverageStats() async {
    final Map<String, Duration> averageMap = {};
    try {
      final DateTime now = DateTimeHelper.now;
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
