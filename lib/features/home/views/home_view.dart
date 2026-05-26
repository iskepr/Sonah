import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/service/ticker_service.dart";
import "../../athan/views/next_athan_view.dart";
import "../../battery/cubit/battery_cubit.dart";
import "../../battery/views/battery_view.dart";
import "../../date_time/views/clock_view.dart";
import "../../date_time/views/hijri_date_view.dart";
import "../../date_time/views/progress_view.dart";
import "../../system_apps/views/system_apps_view.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

// ضفنا الـ with WidgetsBindingObserver هنا عشان الـ Lifecycle يلقط
class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // إلغاء المراقبة لحماية الميموري لما الـ View تموت
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
      ticker.resume();
      context.read<BatteryCubit>().startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: const BoxDecoration(),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProgressView(),
              SizedBox(height: screenHeight * 0.15),
              const FractionallySizedBox(
                widthFactor: 0.7,
                child: Column(
                  spacing: kMediumPadding,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClockView(),
                            HijriDateView(),
                            NextAthanView(),
                          ],
                        ),
                        BatteryView(),
                      ],
                    ),
                    AppsListView(),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (Theme.of(context).platform == TargetPlatform.android) {
                    const intent = AndroidIntent(
                      action: "android.settings.MANAGE_DEFAULT_APPS_SETTINGS",
                    );
                    await intent.launch();
                  }
                },
                icon: const Icon(LucideIcons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
