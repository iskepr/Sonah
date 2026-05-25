import "package:flutter/material.dart";

import "../../date_time/views/clock_view.dart";
import "../../date_time/views/progress_view.dart";
import "../../system_apps/views/system_apps_view.dart";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [ProgressView(), ClockView(), AppsListView()],
    );
  }
}
