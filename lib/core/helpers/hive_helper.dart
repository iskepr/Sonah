import "package:hive_flutter/hive_flutter.dart";
import "package:path_provider/path_provider.dart";

import "../../constant.dart";
import "../utils/platform_utils.dart";

class HiveHelper {
  static const boxes = [
    kBoxSystemApps,
    kBoxSettings,
  ];

  static Future<void> init() async {
    String? path;
    if (!PlatformUtils.isWeb) {
      final dir = await getApplicationSupportDirectory();
      path = dir.path;
    }
    await Hive.initFlutter(path);
    await _openAllBoxes();
  }

  static Future<void> _openAllBoxes() async {
    for (var box in boxes) {
      await Hive.openBox(box);
    }
  }

  static Future<void> clear() async {
    for (var boxName in boxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  }

  static Future<void> saveListData(
    String boxName,
    List<Map<String, dynamic>> data,
  ) async {
    final box = Hive.box(boxName);
    await box.clear();
    await box.addAll(data);
  }

  static List<Map<String, dynamic>> getListData(String boxName) {
    final box = Hive.box(boxName);
    if (box.isEmpty) return [];

    return box.values.map((e) {
      final map = e as Map;
      return map.cast<String, dynamic>();
    }).toList();
  }

  static Future<void> saveMapData(
    String boxName,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box(boxName);
    await box.clear();
    await box.putAll(data);
  }

  static Map<String, dynamic> getMapData(String boxName) {
    final box = Hive.box(boxName);
    if (box.isEmpty) return {};

    return Map<String, dynamic>.from(box.toMap());
  }

  static List<dynamic> getListDataByKey(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) ?? [];
  }

  static Future<void> saveListDataByKey(
    String boxName,
    String key,
    List<dynamic> data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  static T? getTDataByKey<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data == null) return null;
    return data as T;
  }

  static Future<void> saveTDataByKey<T>(
    String boxName,
    String key,
    T data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }
}
