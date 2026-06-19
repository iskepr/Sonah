import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../../../core/utils/show_message.dart";
import "../../athan/cubit/athan_cubit.dart";
import "../cubit/azkar_cubit.dart";

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit(athanCubit: context.read<AthanCubit>()),
      child: BlocConsumer<AzkarCubit, AzkarState>(
        listener: (context, state) {
          if (state is AzkarFinished) showMessage(l10n.messageAfterFinishAzkar);
        },
        builder: (context, state) {
          if (state is AzkarLoaded) {
            if (state.azkarList.isEmpty) return const SizedBox.shrink();

            if (_currentIndex >= state.azkarList.length) _currentIndex = 0;

            final zekr = state.azkarList[_currentIndex];
            final currentCount = state.currentCounts[_currentIndex] ?? 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kLargePadding * 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        state.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kMediumFont,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "${_currentIndex + 1}/${state.azkarList.length}",
                        style: const TextStyle(
                          fontSize: kSoSmallFont,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: kSmallPadding),
                AnimatedSwitcher(
                  duration: kAnimationFasterDuration,
                  transitionBuilder: (child, Animation<double> animation) {
                    final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
                        .animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: kCurveEaseInOut,
                          ),
                        );

                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    key: ValueKey<int>(_currentIndex),
                    margin: const EdgeInsets.symmetric(
                      horizontal: kLargePadding,
                      vertical: kSmallPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kSmallBorderRadius),
                    ),
                    color: context.colorScheme.primaryContainer,
                    child: InkWell(
                      onTap: () {
                        context.read<AzkarCubit>().decrementCounter(
                          _currentIndex,
                          () => setState(() => _currentIndex++),
                        );
                      },
                      onLongPress: () =>
                          Clipboard.setData(ClipboardData(text: zekr.content)),
                      borderRadius: BorderRadius.circular(kSmallBorderRadius),
                      child: Padding(
                        padding: const EdgeInsets.all(kLargePadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: kMediumPadding,
                          children: [
                            Text(
                              zekr.content,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: kMediumFont + 2,
                                height: 1.5,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: kSmallPadding,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  kSmallBorderRadius,
                                ),
                              ),
                              child: Text(
                                "$currentCount",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: kLargeFont,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
