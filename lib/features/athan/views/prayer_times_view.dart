import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/extensions/date_time_extensions.dart";
import "../../../core/theme/colors.dart";
import "../cubit/athan_cubit.dart";
import "../extensions/athan_extenstion.dart";

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  bool isFullView = false;
  final List<String> prayers = Prayer.values
      .map((e) => e.name)
      .toList()
      .sublist(1)
      .toList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AthanCubit, AthanState>(
      builder: (context, state) {
        if (state is AthanLoaded) {
          return GestureDetector(
            onTap: () => setState(() => isFullView = !isFullView),
            child: AnimatedSize(
              duration: kAnimationDuration,
              child: SizedBox(
                height: isFullView ? 80 : 35,
                child: ListView.builder(
                  itemCount: prayers.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final Prayer prayer = Prayer.values
                        .sublist(1)
                        .toList()[index];

                    return SinglePrayerView(
                      isHidden: !isFullView && prayer != state.nextPrayer,
                      isRemainingView: !isFullView,
                      isNextPrayer: prayer == state.nextPrayer,
                      prayer: prayer,
                      time:
                          state.prayerTimes.timeForPrayer(prayer) ??
                          DateTime.now(),
                      remainingTime: state.remainingTime,
                    );
                  },
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

class SinglePrayerView extends StatefulWidget {
  const SinglePrayerView({
    super.key,
    required this.isHidden,
    required this.isRemainingView,
    required this.isNextPrayer,
    required this.prayer,
    required this.time,
    this.remainingTime,
  });

  final bool isHidden;
  final bool isRemainingView;
  final bool isNextPrayer;
  final Prayer prayer;
  final DateTime time;
  final String? remainingTime;

  @override
  State<SinglePrayerView> createState() => _SinglePrayerViewState();
}

class _SinglePrayerViewState extends State<SinglePrayerView> {
  var isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = kMediumFont / (widget.isRemainingView ? 1 : 1.5);
    final content = Flex(
      direction: widget.isRemainingView ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: widget.isRemainingView ? kSmallPadding : 0,
      children: [
        Icon(
          widget.prayer.prayerIcon,
          size: fontSize * 1.5,
          color: context.colorScheme.primary,
        ),
        Text(
          widget.prayer.prayerName,
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.isRemainingView) ...[
          Text(
            l10n.within,
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
          Text(
            (widget.isNextPrayer && widget.remainingTime != null)
                ? widget.remainingTime!
                : widget.time.differenceToFormattedString(),
            style: TextStyle(
              fontSize: fontSize * 1.1,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
        ] else ...[
          Text(widget.time.toTimeOnly(), style: TextStyle(fontSize: fontSize)),
        ],
      ],
    );

    return GestureDetector(
      onLongPress: () => setState(() => isExpanded = !isExpanded),
      child: Container(
        margin: !widget.isNextPrayer && widget.isRemainingView
            ? EdgeInsets.zero
            : widget.isHidden || widget.isRemainingView
            ? EdgeInsetsDirectional.only(start: screenWidth * 0.13)
            : const EdgeInsets.symmetric(
                horizontal: kSmallPadding / 1.5,
                vertical: kSmallPadding,
              ),
        padding: widget.isHidden || widget.isRemainingView
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(
                vertical: kSmallPadding,
                horizontal: kLargePadding / 1.5,
              ),
        decoration: BoxDecoration(
          color: widget.isHidden || widget.isRemainingView
              ? null
              : context.colorScheme.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(kSmallBorderRadius / 2),
          border: widget.isNextPrayer && !widget.isRemainingView
              ? Border.all(color: context.colorScheme.primary)
              : null,
        ),
        child: AnimatedSize(
          duration: kAnimationDuration,
          curve: kCurveEaseInOut,
          child: widget.isHidden ? const SizedBox.shrink() : content,
        ),
      ),
    );
  }
}
