import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../cubits/progress_cubit.dart";

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        if (state is ProgressLoaded) {
          final defsPers = state.pers.clamp(0, 100);
          return GestureDetector(
            onTap: () => context.read<ProgressCubit>().toggleMode(),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(kMediumPadding),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(kCircleBorderRadius),
              ),
              child: AnimatedFractionallySizedBox(
                duration: kAnimationDuration,
                widthFactor: (defsPers / 100).clamp(0.3, 1),
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  alignment: AlignmentDirectional.topStart,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kMediumPadding,
                    vertical: kSmallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(kCircleBorderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.now,
                        style: TextStyle(
                          color: context.colorScheme.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${defsPers.toInt()}%",
                        style: TextStyle(
                          color: context.colorScheme.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
