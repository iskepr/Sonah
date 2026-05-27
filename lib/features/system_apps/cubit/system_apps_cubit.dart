import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/helpers/hive_helper.dart";
import "../../../core/utils/platform_utils.dart";
import "../models/application_model.dart";

class SystemAppsState {}

class SystemAppsInitial extends SystemAppsState {}

class SystemAppsLoading extends SystemAppsState {}

class SystemAppsLoaded extends SystemAppsState {
  final List<ApplicationModel> apps;
  final int appsCount;
  SystemAppsLoaded({required this.apps, required this.appsCount});
}

class SystemAppsCubit extends Cubit<SystemAppsState> {
  SystemAppsCubit() : super(SystemAppsInitial()) {
    getApps();
  }

  List<ApplicationModel> apps = [];
  StreamSubscription<AppChangeEvent>? _appsSubscription;

  void getApps() async {
    if (!PlatformUtils.isAndroid) {
      safeEmit(SystemAppsLoaded(apps: [], appsCount: 0));
      return;
    }

    final cachedData = HiveHelper.getListData(kBoxSystemApps);
    if (cachedData.isNotEmpty) {
      apps = cachedData.map((map) => ApplicationModel.fromMap(map)).toList();
      safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    } else {
      safeEmit(SystemAppsLoading());
    }

    final List<AppInfo> appsInfo = await FlutterDeviceApps.listApps(
      includeSystem: true,
      includeIcons: true,
      onlyLaunchable: true,
    );

    if (appsInfo.isEmpty) {
      if (apps.isEmpty) safeEmit(SystemAppsLoaded(apps: [], appsCount: 0));
      return;
    }

    apps = appsInfo.map((info) {
      final oldApp = apps.firstWhere(
        (element) => element.appInfo.packageName == info.packageName,
        orElse: () => ApplicationModel(appInfo: info),
      );
      return oldApp.copyWith(appInfo: info);
    }).toList();

    _sortApps(apps);

    _saveToHive();

    safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    _startListeningToChanges();
  }

  void _saveToHive() {
    final dataToSave = apps.map((app) => app.toMap()).toList();
    HiveHelper.saveListData(kBoxSystemApps, dataToSave);
  }

  void _sortApps(List<ApplicationModel> list) {
    list.sort(
      (a, b) => (a.appInfo.appName ?? "").toLowerCase().compareTo(
        (b.appInfo.appName ?? "").toLowerCase(),
      ),
    );
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
          apps.add(ApplicationModel(appInfo: newApp));
          _sortApps(apps);
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
            _sortApps(apps);
            hasChanged = true;
          }
        }
      }

      if (hasChanged) {
        _saveToHive(); // حفظ التعديل الجديد في الكاش
        safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
      }
    }, onError: (error) => debugPrint("خطأ في تتبع التغييرات: $error"));
  }

  Future<void> toggleFavorite(String packageName, bool isFavorite) async {
    final index = apps.indexWhere(
      (app) => app.appInfo.packageName == packageName,
    );
    if (index != -1) {
      apps[index] = apps[index].copyWith(isFavorite: isFavorite);
      _saveToHive();
      safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    }
  }

  Future<void> toggleHidden(String packageName, bool isHidden) async {
    final index = apps.indexWhere(
      (app) => app.appInfo.packageName == packageName,
    );
    if (index != -1) {
      apps[index] = apps[index].copyWith(isHidden: isHidden);
      _saveToHive();
      safeEmit(SystemAppsLoaded(apps: apps, appsCount: apps.length));
    }
  }

  @override
  Future<void> close() {
    _appsSubscription?.cancel();
    return super.close();
  }
}
