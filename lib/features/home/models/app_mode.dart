import "package:hive/hive.dart";
part "app_mode.g.dart";

@HiveType(typeId: 2)
enum AppMode {
  @HiveField(0)
  normal("العادي"),
  @HiveField(1)
  focus("التركيز"),
  @HiveField(2)
  prayer("الصلاة"),
  @HiveField(3)
  sleep("النوم"),
  @HiveField(4)
  search("البحث");

  final String label;
  const AppMode(this.label);
}