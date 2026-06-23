import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/service/ticker_service.dart";
import "../../../core/utils/platform_utils.dart";
import "../models/application_model.dart";
import "../repo/system_apps_repository.dart";
import "system_apps_state.dart";

export "system_apps_state.dart";

class SystemAppsCubit extends Cubit<SystemAppsState> {
  final TickerService tickerService;
  final SystemAppsRepository repository;

  StreamSubscription<DateTime>? _tickerSubscription;
  StreamSubscription<AppChangeEvent>? _appsSubscription;
  List<ApplicationModel> apps = [];

  SystemAppsCubit({required this.tickerService, required this.repository})
    : super(SystemAppsInitial());

  void getApps() async {
    if (!PlatformUtils.isAndroid) {
      safeEmit(SystemAppsLoaded(apps: [], appsCount: 0));
      return;
    }

    // قراءة الكاش وعرضه فوراً
    apps = repository.getCachedApps();
    if (apps.isNotEmpty) {
      safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    } else {
      safeEmit(SystemAppsLoading());
    }

    // جلب تطبيقات السيستم
    apps = await repository.fetchDeviceApps(apps);
    repository.cacheApps(apps);
    safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));

    // تحديث أوقات الاستخدام
    await refreshUsageStats();

    _startListeningToChanges();
    _listenToCentralTicker();
  }

  Future<void> refreshUsageStats() async {
    if (!PlatformUtils.isAndroid || apps.isEmpty) return;

    final usageMap = await repository.fetchTodayUsageMap();

    apps = apps.map((app) {
      return app.copyWith(usageTime: usageMap[app.appInfo.packageName]);
    }).toList();

    apps = repository.sortApps(apps);
    repository.cacheApps(apps);
    safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
  }

  void _listenToCentralTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription = tickerService.timeStream.listen((now) {
      if (now.second % 15 == 0) refreshUsageStats();
    });
  }

  void _startListeningToChanges() {
    _appsSubscription = FlutterDeviceApps.appChanges.listen((
      AppChangeEvent event,
    ) async {
      final String packageName = event.packageName ?? "";
      bool hasChanged = false;

      if (event.type == AppChangeType.removed) {
        apps.removeWhere((app) => app.appInfo.packageName == packageName);
        hasChanged = true;
      } else if (event.type == AppChangeType.installed) {
        final AppInfo? newApp = await FlutterDeviceApps.getApp(
          packageName,
          includeIcon: true,
        );
        if (newApp != null) {
          apps.add(ApplicationModel(appInfoMap: appInfoToMap(newApp)));
          repository.sortApps(apps);
          hasChanged = true;
        }
      } else if (event.type == AppChangeType.updated) {
        final AppInfo? updatedApp = await FlutterDeviceApps.getApp(
          packageName,
          includeIcon: true,
        );
        if (updatedApp != null) {
          final int index = apps.indexWhere(
            (app) => app.appInfo.packageName == packageName,
          );
          if (index != -1) {
            apps[index] = apps[index].copyWith(appInfo: updatedApp);
            repository.sortApps(apps);
            hasChanged = true;
          }
        }
      }

      if (hasChanged) await refreshUsageStats();
    }, onError: (error) => debugPrint("خطأ في تتبع التغييرات: $error"));
  }

  Future<void> toggleFavorite(String packageName, bool isFavorite) async {
    _updateAppProperty(
      packageName,
      (app) => app.copyWith(isFavorite: isFavorite),
    );
  }

  Future<void> toggleHidden(String packageName, bool isHidden) async {
    _updateAppProperty(packageName, (app) => app.copyWith(isHidden: isHidden));
  }

  Future<void> incrementOpenCount(String packageName) async {
    _updateAppProperty(
      packageName,
      (app) => app.copyWith(
        openCount: app.openCount + 1,
        lastOpenTime: DateTimeHelper.now,
      ),
    );
  }

  void _updateAppProperty(
    String packageName,
    ApplicationModel Function(ApplicationModel) update,
  ) {
    final index = apps.indexWhere(
      (app) => app.appInfo.packageName == packageName,
    );
    if (index != -1) {
      apps[index] = update(apps[index]);
      repository.cacheApps(apps);
      safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    }
  }

  @override
  Future<void> close() {
    _appsSubscription?.cancel();
    _tickerSubscription?.cancel();
    return super.close();
  }
}
