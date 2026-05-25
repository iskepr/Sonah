import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../cubits/clock_cubit.dart";

class ClockView extends StatelessWidget {
  const ClockView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, ClockState>(
      builder: (context, state) {
        if (state is ClockLoaded) {
          return Text(
            state.clock,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
