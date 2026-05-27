import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "../cubit/system_apps_cubit.dart";
import "../models/application_model.dart";

class AppsListView extends StatelessWidget {
  const AppsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemAppsCubit, SystemAppsState>(
      builder: (context, state) {
        if (state is! SystemAppsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final apps = state.apps
            .where((app) => app.isFavorite && !app.isHidden)
            .toList();
        return AppsListTile(apps: apps, cubit: context.read<SystemAppsCubit>());
      },
    );
  }
}

class AppsListTile extends StatelessWidget {
  const AppsListTile({super.key, required this.apps, required this.cubit});
  final List<ApplicationModel> apps;
  final SystemAppsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: apps.length,
      itemBuilder: (context, index) {
        final ApplicationModel app = apps[index];
        final appName = app.appInfo.appName ?? "";
        final String packageName = app.appInfo.packageName ?? "";
        final bool isFavorite = app.isFavorite;
        final bool isHidden = app.isHidden;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: kSmallPadding * 0.3,
          ),
          leading: AppIcon(iconBytes: app.appInfo.iconBytes),
          title: Text(appName),
          onLongPress: () async {
            showMyBottomSheet(
              context: context,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(appName),
                    leading: AppIcon(iconBytes: app.appInfo.iconBytes),
                    subtitle: const Text("3 ساعات"),
                    trailing: const Icon(LucideIcons.circleAlert),
                    onTap: () async =>
                        await FlutterDeviceApps.openAppSettings(packageName),
                  ),
                  ListTile(
                    title: Text(
                      "${isFavorite ? "${l10n.remove} ${l10n.from}" : "${l10n.add} ${l10n.to}"} ${l10n.favorite}",
                    ),
                    leading: Icon(
                      isFavorite ? LucideIcons.starOff : LucideIcons.star,
                    ),
                    onTap: () async {
                      await cubit.toggleFavorite(packageName, !isFavorite);
                      if (context.mounted) context.close();
                    },
                  ),
                  ListTile(
                    title: Text(l10n.edit),
                    leading: const Icon(LucideIcons.edit),
                    onTap: () async {
                      await cubit.toggleHidden(packageName, !isHidden);
                      if (context.mounted) context.close();
                    },
                  ),
                  ListTile(
                    title: Text(isHidden ? l10n.showApp : l10n.hideApp),
                    leading: Icon(
                      isHidden ? LucideIcons.eyeClosed : LucideIcons.eye,
                    ),
                    onTap: () async {
                      await cubit.toggleHidden(packageName, !isHidden);
                      if (context.mounted) context.close();
                    },
                  ),
                  if (!(app.appInfo.isSystem ?? false))
                    ListTile(
                      title: Text(l10n.unInstall),
                      leading: const Icon(LucideIcons.trash2),
                      onTap: () async {
                        await FlutterDeviceApps.uninstallApp(packageName);
                        if (context.mounted) context.close();
                      },
                    ),
                ],
              ),
            );
          },
          onTap: () async => await FlutterDeviceApps.openApp(packageName),
        );
      },
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.iconBytes});
  final Uint8List? iconBytes;

  @override
  Widget build(BuildContext context) {
    if (iconBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(kLargeFont / 1.5),
        child: Image.memory(iconBytes!, width: kLargeFont * 1.8),
      );
    } else {
      return const Icon(LucideIcons.circleAlert, size: kLargeFont * 1.8);
    }
  }
}
