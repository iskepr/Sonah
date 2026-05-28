// home_view.dart
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/service/ticker_service.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "../../athan/views/prayer_times_view.dart";
import "../../battery/cubit/battery_cubit.dart";
import "../../battery/views/battery_view.dart";
import "../../date_time/views/clock_view.dart";
import "../../date_time/views/full_date_view.dart";
import "../../search/views/search_view.dart";
import "../../settings/views/settings_view.dart";
import "../../system_apps/views/system_apps_view.dart";
import "../../top_bar/views/top_bar_view.dart";
import "../cubit/home_cubit.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _homeCubit = HomeCubit(
      tickerService: context.read<TickerService>(),
      batteryCubit: context.read<BatteryCubit>(),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _homeCubit.handleAppLifecycle(state);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final kDefaultPadding = screenWidth * 0.13;

    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final isSearchMode = state.isSearchMode;

          return GestureDetector(
            onLongPress: () => showMyBottomSheet(
              context: context,
              child: const SettingsView(),
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.dragDetails != null) {
                  _homeCubit.handleScrollVelocity(
                    notification.dragDetails!.primaryVelocity!,
                  );
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: kAnimationDuration,
                        height: isSearchMode ? screenHeight * 0.11 : 0,
                        curve: Curves.easeInOut,
                      ),

                      TopBarView(isSearchMode: isSearchMode),

                      AnimatedOpacity(
                        duration: kAnimationDuration,
                        curve: kCurveEaseInOut,
                        opacity: isSearchMode ? 1 : 0,
                        child: Visibility(
                          visible: isSearchMode,
                          maintainState: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                            ),
                            child: const SearchView(),
                          ),
                        ),
                      ),

                      AnimatedContainer(
                        duration: kAnimationDuration,
                        height: !isSearchMode ? screenHeight * 0.11 : 0,
                        curve: Curves.easeInOut,
                      ),

                      AnimatedOpacity(
                        duration: kAnimationDuration,
                        curve: kCurveEaseInOut,
                        opacity: isSearchMode ? 0 : 1,
                        child: Visibility(
                          visible: !isSearchMode,
                          maintainState: false,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding,
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClockView(),
                                    Row(
                                      spacing: kMediumPadding,
                                      children: [FullDateView(), BatteryView()],
                                    ),
                                  ],
                                ),
                              ),
                              const PrayerTimesView(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding,
                                ),
                                child: const AppsListView(),
                              ),
                            ],
                          ),
                        ),
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
