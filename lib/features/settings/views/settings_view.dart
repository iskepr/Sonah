import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../core/utils/platform_utils.dart";

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(LucideIcons.settings),
          title: const Text("تعين كمشغل افتراضي"),
          onTap: () async {
            if (PlatformUtils.isAndroid) {
              const intent = AndroidIntent(
                action: "android.settings.MANAGE_DEFAULT_APPS_SETTINGS",
              );
              await intent.launch();
            }
          },
        ),
      ],
    );
  }
}
