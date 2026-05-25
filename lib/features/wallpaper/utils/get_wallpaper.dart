import "dart:typed_data";

import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:wallpaper_handler/wallpaper_handler.dart";

Future<Uint8List?> getWallPaper() async {
  final status = await Permission.storage.request();

  if (status.isGranted) {
    try {
      final Uint8List? bytes = await WallpaperHandler.instance.getWallpaper(
        WallpaperLocation.homeScreen,
      );
      return bytes;
    } catch (e) {
      debugPrint("إيرور في جلب الخلفية: $e");
    }
  } else {
    debugPrint("المستخدم رفض صلاحية الملفات");
  }
  return null;
}
