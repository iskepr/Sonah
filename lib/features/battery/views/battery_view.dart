import "package:battery_plus/battery_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../cubit/battery_cubit.dart";

class BatteryView extends StatelessWidget {
  const BatteryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BatteryCubit(),
      child: BlocBuilder<BatteryCubit, BatteryCubitState>(
        builder: (context, state) {
          if (state is BatteryLoaded) {
            final bl = state.batteryLevel;
            final bs = state.batteryState;
            return Row(
              spacing: kSmallPadding,
              children: [
                Text("$bl%"),
                if (bs == BatteryState.charging)
                  const Icon(LucideIcons.batteryCharging)
                else if (bs == BatteryState.full)
                  const Icon(LucideIcons.batteryFull)
                else if (bs == BatteryState.connectedNotCharging)
                  const Icon(LucideIcons.batteryWarning)
                else if (bs == BatteryState.unknown)
                  const Icon(LucideIcons.battery)
                else if (bl < 10)
                  const Icon(LucideIcons.batteryWarning)
                else if (bl < 20)
                  const Icon(LucideIcons.batteryLow)
                else if (bl <= 50)
                  const Icon(LucideIcons.batteryMedium)
                else
                  const Icon(LucideIcons.batteryFull),
              ],
            );
          }
          return const Icon(LucideIcons.battery);
        },
      ),
    );
  }
}
