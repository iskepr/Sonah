import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "constant.dart";
import "core/theme/colors.dart";
import "features/home/views/home_view.dart";
import "generated/l10n.dart";

void main() {
  runApp(const Sonah());
}

class Sonah extends StatelessWidget {
  const Sonah({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "سُنة",

      navigatorKey: kNavigatorKey,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,

      // لغة التطبيق
      locale: const Locale("ar"),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      home: const Scaffold(body: HomeView()),

      // الوان التطبيق
      themeMode: ThemeMode.system,
      theme: AppThemes.darkTheme,
      darkTheme: AppThemes.darkTheme,
    );
  }
}
