import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/widgets/show_dialog.dart";
import "../cubit/athan_cubit.dart";
import "prayer_times_view.dart";

class NextAthanView extends StatelessWidget {
  const NextAthanView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AthanCubit, AthanState>(
      builder: (context, state) {
        if (state is AthanLoaded) {
          return GestureDetector(
            child: Text(
              "${state.nextPrayerName} ${l10n.within} ${state.remainingTime}",
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () => showCustomDialog(
              title: l10n.prayerTimes,
              child: PrayerTimesView(prayerTimes: state.prayerTimes),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
