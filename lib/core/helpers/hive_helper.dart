import "package:hive_flutter/hive_flutter.dart";
import "package:path_provider/path_provider.dart";

import "../../constant.dart";
import "../../features/home/models/app_mode.dart";
import "../../features/routine/models/task_model.dart";
import "../../features/system_apps/models/application_model.dart";
import "../utils/platform_utils.dart";

class HiveHelper {
  static const boxes = [kBoxSystemApps, kBoxSettings, kBoxAzkar, kBoxRoutine];

  static Future<void> init() async {
    String? path;
    if (!PlatformUtils.isWeb) {
      final dir = await getApplicationSupportDirectory();
      path = dir.path;
    }
    await Hive.initFlutter(path);

    Hive.registerAdapter(ApplicationModelAdapter());
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(AppModeAdapter());
    Hive.registerAdapter(TaskAdapter());

    await _openAllBoxes();
  }

  static Future<void> _openAllBoxes() async {
    await Hive.openBox<ApplicationModel>(kBoxSystemApps);
    await Hive.openBox<Task>(kBoxRoutine);
    await Hive.openBox(kBoxSettings);
  }

  static Future<void> clear() async {
    await Hive.box<ApplicationModel>(kBoxSystemApps).clear();
    await Hive.box<Task>(kBoxRoutine).clear();
    await Hive.box(kBoxSettings).clear();
  }

  static Future<void> saveListData<T>(String boxName, List<T> data) async {
    final box = Hive.box<T>(boxName);
    await box.clear();
    await box.addAll(data);
  }

  static List<T> getListData<T>(String boxName) {
    final box = Hive.box<T>(boxName);
    if (box.isEmpty) return [];
    return box.values.toList();
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

  static Future<void> saveDataByKey<T>(
    String boxName,
    String key,
    T data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  static T? getDataByKey<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data == null) return null;

    if (data is Map && T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(data) as T;
    }

    return data as T;
  }
}
