import "package:battery_plus/battery_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../cubit/battery_cubit.dart";

class BatteryView extends StatelessWidget {
  const BatteryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteryCubit, BatteryCubitState>(
      builder: (context, state) {
        if (state is BatteryLoaded) {
          final bl = state.batteryLevel;
          final bs = state.batteryState;

          final Color? iconColor = switch ((bl, bs)) {
            (final int level, _) when level < 10 => context.error,
            (final int level, _) when level < 25 => context.warning,
            (100, BatteryState.charging) => context.error,
            (_, BatteryState.charging) => context.success,
            _ => null,
          };

          return Row(
            spacing: kSmallPadding,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bl < 90) Text("$bl%", style: TextStyle(color: iconColor)),
              Icon(_getBatteryIconData(bs, bl), color: iconColor),
            ],
          );
        }
        return const Icon(LucideIcons.battery);
      },
    );
  }

  IconData? _getBatteryIconData(BatteryState state, int level) {
    if (state == BatteryState.charging) return LucideIcons.batteryCharging;
    // if (state == BatteryState.full) return LucideIcons.batteryFull;
    if (state == BatteryState.connectedNotCharging) {
      return LucideIcons.batteryWarning;
    }
    if (state == BatteryState.unknown) return LucideIcons.battery;

    if (level < 10) return LucideIcons.batteryWarning;
    if (level < 20) return LucideIcons.batteryLow;
    if (level <= 50) return LucideIcons.batteryMedium;
    return null;
  }
}
