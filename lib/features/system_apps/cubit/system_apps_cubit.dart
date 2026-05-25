import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/utils/platform_utils.dart";

class SystemAppsState {}

class SystemAppsInitial extends SystemAppsState {}

class SystemAppsLoading extends SystemAppsState {}

class SystemAppsLoaded extends SystemAppsState {
  final List<AppInfo> apps;
  final int appsCount;
  SystemAppsLoaded({required this.apps, required this.appsCount});
}

class SystemAppsCubit extends Cubit<SystemAppsState> {
  SystemAppsCubit() : super(SystemAppsInitial());

  List<AppInfo> _apps = [];

  StreamSubscription<AppChangeEvent>? _appsSubscription;

  void getApps() async {
    if (!PlatformUtils.isAndroid) {
      safeEmit(SystemAppsLoaded(apps: [], appsCount: 0));
      return;
    }

    safeEmit(SystemAppsLoading());

    _apps = await FlutterDeviceApps.listApps(
      includeSystem: true,
      includeIcons: true,
      onlyLaunchable: true,
    );

    _sortApps(_apps);

    safeEmit(SystemAppsLoaded(apps: _apps, appsCount: _apps.length));

    _startListeningToChanges();
  }

  void _sortApps(List<AppInfo> list) {
    list.sort(
      (a, b) => (a.appName ?? "").toLowerCase().compareTo(
        (b.appName ?? "").toLowerCase(),
      ),
    );
  }

  void _startListeningToChanges() {
    _appsSubscription = FlutterDeviceApps.appChanges.listen(
      (AppChangeEvent event) async {
        final String packageName = event.packageName ?? "";
        debugPrint("App change event: ${event.toMap()}");

        if (event.type == AppChangeType.removed) {
          _apps.removeWhere((app) => app.packageName == packageName);
          safeEmit(SystemAppsLoaded(apps: _apps, appsCount: _apps.length));
        } else if (event.type == AppChangeType.installed) {
          final AppInfo? newApp = await FlutterDeviceApps.getApp(
            packageName,
            includeIcon: true,
          );

          if (newApp != null) {
            _apps.add(newApp);
            _sortApps(_apps);
            safeEmit(SystemAppsLoaded(apps: _apps, appsCount: _apps.length));
          }
        } else if (event.type == AppChangeType.updated) {
          final AppInfo? updatedApp = await FlutterDeviceApps.getApp(
            packageName,
            includeIcon: true,
          );

          if (updatedApp != null) {
            final int index = _apps.indexWhere(
              (app) => app.packageName == packageName,
            );
            if (index != -1) {
              _apps[index] = updatedApp;
              _sortApps(_apps);
            }
            safeEmit(SystemAppsLoaded(apps: _apps, appsCount: _apps.length));
          }
        }
      },
      onError: (error) {
        debugPrint("خطأ في تتبع التغييرات: $error");
      },
    );
  }

  @override
  Future<void> close() {
    _appsSubscription?.cancel();
    debugPrint("SystemAppsCubit closed");
    return super.close();
  }
}
