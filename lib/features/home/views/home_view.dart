import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/service/ticker_service.dart";
import "../../../core/utils/platform_utils.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "../../athan/views/prayer_times_view.dart";
import "../../battery/cubit/battery_cubit.dart";
import "../../battery/views/battery_view.dart";
import "../../date_time/views/clock_view.dart";
import "../../date_time/views/full_date_view.dart";
import "../../date_time/views/progress_view.dart";
import "../../system_apps/cubit/system_apps_cubit.dart";
import "../../system_apps/views/system_apps_view.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final ticker = context.read<TickerService>();

    if (state == AppLifecycleState.paused) {
      ticker.pause();
      context.read<BatteryCubit>().stopListening();
    } else if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      ticker.resume();
      context.read<BatteryCubit>().startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < 0) {
          showMyBottomSheet(
            context: context,
            child: AppsListTile(
              apps: context.read<SystemAppsCubit>().apps,
              cubit: context.read<SystemAppsCubit>(),
            ),
          );
        }
      },
      onLongPress: () => showMyBottomSheet(
        context: context,
        child: Column(
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
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProgressView(),
                SizedBox(height: screenHeight * 0.15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClockView(),
                      Row(
                        spacing: kMediumPadding,
                        children: [FullDateView(), BatteryView()],
                      ),
                    ],
                  ),
                ),
                const PrayerTimesView(),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: const AppsListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
