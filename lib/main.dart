import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "constant.dart";
import "core/helpers/hive_helper.dart";
import "core/service/ticker_service.dart";
import "core/theme/colors.dart";
import "features/athan/cubit/athan_cubit.dart";
import "features/battery/cubit/battery_cubit.dart";
import "features/date_time/cubits/clock_cubit.dart";
import "features/date_time/cubits/progress_cubit.dart";
import "features/home/views/home_view.dart";
import "features/search/cubit/search_cubit.dart";
import "features/system_apps/cubit/system_apps_cubit.dart";
import "generated/l10n.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();

  runApp(const Sonah());
}

class Sonah extends StatelessWidget {
  const Sonah({super.key});

  @override
  Widget build(BuildContext context) {
    final tickerService = TickerService();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: "سُنة",

          navigatorKey: kNavigatorKey,
          scaffoldMessengerKey: messengerKey,
          debugShowCheckedModeBanner: false,

          // لغة التطبيق
          locale: const Locale(kAppLang),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          home: RepositoryProvider<TickerService>.value(
            value: tickerService,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      AthanCubit(tickerService: context.read<TickerService>()),
                ),
                BlocProvider(
                  create: (context) =>
                      ClockCubit(tickerService: context.read<TickerService>()),
                ),
                BlocProvider(
                  create: (context) => BatteryCubit(
                    tickerService: context.read<TickerService>(),
                  ),
                ),
                BlocProvider(create: (context) => SystemAppsCubit()),
                BlocProvider(create: (context) => ProgressCubit()),
                BlocProvider(create: (context) => SearchCubit(allApps: context.read<SystemAppsCubit>().apps)),
              ],
              child: const Scaffold(
                backgroundColor: Colors.transparent,
                body: HomeView(),
              ),
            ),
          ),

          themeMode: ThemeMode.system,
          theme: AppThemes.lightTheme(lightDynamic),
          darkTheme: AppThemes.darkTheme(darkDynamic),
        );
      },
    );
  }
}
