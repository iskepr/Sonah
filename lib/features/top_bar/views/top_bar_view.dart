import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../../search/cubit/search_cubit.dart";
import "../../date_time/cubits/progress_cubit.dart";

class TopBarView extends StatelessWidget {
  const TopBarView({super.key, required this.isSearchMode});
  final bool isSearchMode;

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<SearchCubit>();

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
              child: TopBarContentView(
                isSearchMode: isSearchMode,
                searchCubit: searchCubit,
                defsPers: defsPers,
                title: state.title,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class TopBarContentView extends StatelessWidget {
  const TopBarContentView({
    super.key,
    required this.isSearchMode,
    required this.searchCubit,
    required this.defsPers,
    required this.title,
  });

  final bool isSearchMode;
  final SearchCubit searchCubit;
  final num defsPers;
  final String title;

  @override
  Widget build(BuildContext context) {
    final double availableWidth =
        MediaQuery.sizeOf(context).width - kMediumPadding;

    final double targetWidth = isSearchMode
        ? 0
        : (availableWidth * (defsPers / 100)).clamp(
            availableWidth * 0.3,
            availableWidth,
          );

    return Row(
      children: [
        AnimatedContainer(
          duration: kAnimationDuration,
          width: targetWidth,
          curve: kCurveEaseInOut,
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.symmetric(
            horizontal: kMediumPadding,
            vertical: kSmallPadding,
          ),
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(kCircleBorderRadius),
          ),
          child: SizedBox(
            width:
                (availableWidth * (defsPers / 100)).clamp(
                  availableWidth * 0.3,
                  availableWidth * 0.8,
                ) -
                (kMediumPadding * 2),
            child: Row(
              spacing: kSmallPadding,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
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

        if (isSearchMode)
          Expanded(
            child: AnimatedOpacity(
              duration: kAnimationDuration,
              opacity: isSearchMode ? 1 : 0,
              child: IgnorePointer(
                ignoring: !isSearchMode,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kLargePadding,
                  ),
                  child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: "ابحث في التطبيقات، الأسماء، أو جوجل...",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: kMediumPadding * 0.8,
                      ),
                    ),
                    onChanged: (value) => searchCubit.search(value),
                    onSubmitted: (value) async =>
                        await searchCubit.handleSubmitted(value, context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
