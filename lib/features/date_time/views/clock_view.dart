import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../../core/utils/platform_utils.dart";
import "../cubits/clock_cubit.dart";

class ClockView extends StatelessWidget {
  const ClockView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, ClockState>(
      builder: (context, state) {
        if (state is ClockLoaded) {
          return GestureDetector(
            onTap: () async {
              if (PlatformUtils.isAndroid) {
                await const AndroidIntent(
                  action: "android.intent.action.SHOW_ALARMS",
                ).launch();
              }
            },
            child: Text(
              state.clock,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
