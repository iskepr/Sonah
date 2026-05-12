import "package:flutter/material.dart";

import "../../clock/views/clock_view.dart";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
      ClockView(),

      ],
    );
  }
}
