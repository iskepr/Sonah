import "package:expandable_page_view/expandable_page_view.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../../../core/utils/show_message.dart";
import "../../athan/cubit/athan_cubit.dart";
import "../cubit/azkar_cubit.dart";
import "widgets/zekr_widget.dart";

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit(athanCubit: context.read<AthanCubit>()),
      child: BlocConsumer<AzkarCubit, AzkarState>(
        listener: (context, state) {
          if (state is AzkarFinished) showMessage(l10n.messageAfterFinishAzkar);
        },
        builder: (context, state) {
          if (state is! AzkarLoaded || state.azkar.data.isEmpty) {
            return const SizedBox.shrink();
          }

          if (_currentIndex >= state.azkar.data.length) _currentIndex = 0;
          return Column(
            spacing: kSmallPadding,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kLargePadding * 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      state.azkar.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: kMediumFont,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      "${_currentIndex + 1}/${state.azkar.data.length}",
                      style: const TextStyle(
                        fontSize: kSoSmallFont,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              ExpandablePageView.builder(
                itemCount: state.azkar.data.length,
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final zekr = state.azkar.data[index];
                  final currentCount = state.currentCounts[index] ?? 0;

                  return ZekrWidget(
                    zekr: zekr,
                    currentCount: currentCount,
                    onPressed: () {
                      context.read<AzkarCubit>().decrementCounter(index, () {
                        if (_currentIndex < state.azkar.data.length - 1) {
                          _pageController.animateToPage(
                            _currentIndex + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
