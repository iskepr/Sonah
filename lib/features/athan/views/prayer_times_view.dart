import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../cubit/athan_cubit.dart";
import "widgets/single_prayer.dart";

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  bool isFullView = false;
  final List<Prayer> prayers = Prayer.values.sublist(1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AthanCubit, AthanState>(
      buildWhen: (previous, current) {
        if (previous is AthanLoaded && current is AthanLoaded) {
          return previous.nextPrayer != current.nextPrayer;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AthanLoaded) {
          return GestureDetector(
            onTap: () => setState(() => isFullView = !isFullView),
            child: SizedBox(
              height: isFullView ? 80 : 35,
              child: ListView.builder(
                itemCount: prayers.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final prayer = prayers[index];

                  if (!isFullView && prayer != state.nextPrayer) {
                    return const SizedBox.shrink();
                  }

                  return SinglePrayer(
                    isHidden: !isFullView && prayer != state.nextPrayer,
                    isRemainingView: !isFullView,
                    isNextPrayer: prayer == state.nextPrayer,
                    prayer: prayer,
                    time:
                        state.prayerTimes.timeForPrayer(prayer) ??
                        DateTime.now(),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
