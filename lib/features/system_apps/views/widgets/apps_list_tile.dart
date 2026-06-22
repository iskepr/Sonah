import "package:flutter/material.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../../constant.dart";
import "../../cubit/system_apps_cubit.dart";
import "../../functions/on_long_press.dart";
import "../../models/application_model.dart";
import "app_icon.dart";

class AppsListTile extends StatelessWidget {
  const AppsListTile({
    super.key,
    required this.apps,
    this.maxCount,
    required this.cubit,
  });
  final List<ApplicationModel> apps;
  final int? maxCount;
  final SystemAppsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,

      itemCount: apps.length.clamp(0, maxCount ?? apps.length),
      itemBuilder: (context, index) {
        final ApplicationModel app = apps[index];
        final appName = app.appInfo.appName ?? "";
        final String packageName = app.appInfo.packageName ?? "";

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: kSmallPadding * 0.3,
          ),
          leading: AppIcon(iconBytes: app.appInfo.iconBytes),
          title: Text(
            appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onLongPress: () => onLongPressApp(context, app, cubit),
          onTap: () async {
            await cubit.incrementOpenCount(packageName);
            await FlutterDeviceApps.openApp(packageName);
          },
        );
      },
    );
  }
}
