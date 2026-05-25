import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../battery/views/battery_view.dart";
import "../../date_time/views/clock_view.dart";
import "../../date_time/views/progress_view.dart";
import "../../system_apps/views/system_apps_view.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  static const platform = MethodChannel("sonah.app/wallpaper");
  Uint8List? _wallpaperBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fetchSystemWallpaper();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchSystemWallpaper();
    }
  }

  Future<void> _fetchSystemWallpaper() async {
    if (!Platform.isAndroid) return;
    try {
      final Uint8List? result = await platform.invokeMethod("getWallpaper");
      if (mounted) {
        setState(() => _wallpaperBytes = result);
      }
    } on PlatformException catch (e) {
      debugPrint("فشل جلب الخلفية: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _wallpaperBytes != null
              ? DecorationImage(
                  image: MemoryImage(_wallpaperBytes!),
                  fit: BoxFit.cover,
                )
              : null,
          color: _wallpaperBytes == null ? Colors.black : null,
        ),
        child: const SafeArea(
          child: Column(
            children: [
              ProgressView(),
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [ClockView(), BatteryView()],
                      ),
                      AppsListView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
