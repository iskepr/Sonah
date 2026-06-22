import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../constant.dart";
import "../../../../core/extensions/date_time_extensions.dart";
import "../../../../core/theme/colors.dart";
import "../../cubit/athan_cubit.dart";
import "../../extensions/athan_extenstion.dart";

class SinglePrayer extends StatefulWidget {
  const SinglePrayer({
    super.key,
    required this.isHidden,
    required this.isRemainingView,
    required this.isNextPrayer,
    required this.prayer,
    required this.time,
  });

  final bool isHidden;
  final bool isRemainingView;
  final bool isNextPrayer;
  final Prayer prayer;
  final DateTime time;

  @override
  State<SinglePrayer> createState() => _SinglePrayerState();
}

class _SinglePrayerState extends State<SinglePrayer> {
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

          BlocBuilder<AthanCubit, AthanState>(
            buildWhen: (previous, current) {
              if (previous is AthanLoaded && current is AthanLoaded) {
                return previous.remainingTime != current.remainingTime;
              }
              return true;
            },
            builder: (context, state) {
              String displayTime = widget.time.differenceToFormattedString();
              if (state is AthanLoaded && widget.isNextPrayer) {
                displayTime = state.remainingTime;
              }

              return Text(
                displayTime,
                style: TextStyle(
                  fontSize: fontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              );
            },
          ),
        ] else ...[
          Text(widget.time.timeOnly(), style: TextStyle(fontSize: fontSize)),
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
