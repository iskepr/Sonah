import "dart:async";
import "package:geolocator/geolocator.dart";
import "package:location/location.dart" as loc;

import "platform_utils.dart";
import "show_message.dart";

Future<Position?> getCurrentLocation() async {
  final Position defaultLocation = Position(
    longitude: 31.2268,
    latitude: 30.0588,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  if (PlatformUtils.isLinux) return defaultLocation;

  try {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        showMessage("لازم تفتح الـ GPS عشان تسجل حُضور", isError: true);
        return null;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showMessage("لازم توافق على صلاحيات الموقع", isError: true);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showMessage(
        "الصلاحيات مرفوضة نهائياً، افتحها من الإعدادات",
        isError: true,
      );
      return null;
    }

    late LocationSettings locationSettings;

    if (PlatformUtils.isWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    } else if (PlatformUtils.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "جاري تحديد موقعك",
          notificationText: "جاري تحديد موقعك بدقة عالية",
          enableWakeLock: true,
          enableWifiLock: true,
        ),
      );
    } else if (PlatformUtils.isIOS || PlatformUtils.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    ).timeout(const Duration(seconds: 15));

    if (position.isMocked) {
      showMessage("بلاش تشغل دماغك.. اقفل الـ Fake GPS", isError: true);
      return null;
    }

    return position;
  } on TimeoutException catch (_) {
    if (PlatformUtils.isWeb) return defaultLocation;
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return lastPosition;
    }
    showMessage("تأخر الاستجابة من الـ GPS");
    return null;
  } catch (e) {
    if (PlatformUtils.isWeb) return defaultLocation;
    showMessage("فشل في الحصول على الموقع");
    return null;
  }
}
