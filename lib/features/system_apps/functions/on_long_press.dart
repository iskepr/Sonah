import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:share_plus/share_plus.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/utils/show_message.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "../cubit/system_apps_cubit.dart";
import "../models/application_model.dart";
import "../views/widgets/app_icon.dart";

void onLongPressApp(
  BuildContext context,
  ApplicationModel app,
  SystemAppsCubit cubit,
) async {
  final appName = app.appInfo.appName ?? "غير معروف";
  final packageName = app.appInfo.packageName;
  showMyBottomSheet(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: AppIcon(iconBytes: app.appInfo.iconBytes),
          subtitle: GestureDetector(
            onTap: () async {
              const intent = AndroidIntent(
                action: "android.settings.USAGE_ACCESS_SETTINGS",
              );
              await intent.launch();
            },
            child: Text(app.usageTime.toHHMM()),
          ),
          trailing: const Icon(LucideIcons.circleAlert),
          onTap: () async =>
              await FlutterDeviceApps.openAppSettings(packageName ?? ""),
        ),
        ListTile(
          title: Text(
            "${app.isFavorite ? "${l10n.remove} ${l10n.from}" : "${l10n.add} ${l10n.to}"} ${l10n.favorite}",
          ),
          leading: Icon(
            app.isFavorite ? LucideIcons.starOff : LucideIcons.star,
          ),
          onTap: () async {
            if (packageName == null) return;
            await cubit.toggleFavorite(packageName, !app.isFavorite);
            if (context.mounted) context.close();
          },
        ),
        ListTile(
          title: Text(l10n.edit),
          leading: const Icon(LucideIcons.edit),
          onTap: () async {
            if (packageName == null) return;
            await cubit.toggleHidden(packageName, !app.isHidden);
            if (context.mounted) context.close();
          },
        ),
        ListTile(
          title: Text(l10n.share),
          leading: const Icon(LucideIcons.share2),
          onTap: () async {
            final String? apkPath = app.appInfo.apkPath;

            if (apkPath != null && apkPath.isNotEmpty) {
              if (context.mounted) context.close();

              try {
                await Share.shareXFiles(
                  [XFile(apkPath)],
                  text: "مشاركة ملف APK لتطبيق $appName",
                  subject: "ملف $appName.apk",
                );
              } catch (e) {
                showMessage(
                  "لا يمكن مشاركة ملف الـ APK لهذا التطبيق",
                  isError: true,
                );
              }
            } else {
              showMessage(
                "لا يمكن الوصول لملف الـ APK لهذا التطبيق",
                isError: true,
              );
            }
          },
        ),
        ListTile(
          title: Text(app.isHidden ? l10n.showApp : l10n.hideApp),
          leading: Icon(app.isHidden ? LucideIcons.eyeClosed : LucideIcons.eye),
          onTap: () async {
            if (packageName == null) return;
            await cubit.toggleHidden(packageName, !app.isHidden);
            if (context.mounted) context.close();
          },
        ),
        if (!(app.appInfo.isSystem ?? false) && packageName != null)
          ListTile(
            title: Text(l10n.unInstall),
            leading: const Icon(LucideIcons.trash2),
            onTap: () async {
              await FlutterDeviceApps.uninstallApp(packageName);
              if (context.mounted) context.close();
            },
          ),

        Center(child: Text(packageName ?? "")),
      ],
    ),
  );
}
