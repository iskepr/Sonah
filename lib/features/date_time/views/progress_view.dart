import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../cubits/progress_cubit.dart";

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit()..getProg(),
      child: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          double defsPers = 1;
          String now = "";

          if (state is ProgressLoaded) {
            defsPers = state.pers.clamp(0, 100);
            now = state.now;
          }

          return GestureDetector(
            onTap: () {
              context.read<ProgressCubit>().toggleMode();
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: context.secondary),
              child: AnimatedFractionallySizedBox(
                duration: kAnimationDuration,
                widthFactor: defsPers / 100,
                alignment: Alignment.topRight,
                child: Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kMediumPadding,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(now, style: TextStyle(color: context.text)),
                      Text(
                        "${defsPers.toInt()}%",
                        style: TextStyle(color: context.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
