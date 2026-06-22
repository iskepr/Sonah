import "dart:typed_data";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../constant.dart";

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.iconBytes});
  final Uint8List? iconBytes;

  @override
  Widget build(BuildContext context) {
    if (iconBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(kAppIconRadius),
        child: Image.memory(iconBytes!, width: kAppIconSize),
      );
    } else {
      return const Icon(LucideIcons.circleAlert, size: kLargeFont * 1.8);
    }
  }
}
