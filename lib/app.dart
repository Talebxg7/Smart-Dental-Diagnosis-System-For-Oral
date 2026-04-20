import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'shared/auth/auth_provider.dart';
import 'shared/api/api_client.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiClient _api;
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _auth = AuthProvider(_api);
    _router = createAppRouter(_auth);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _api),
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier()),
      ],
      child: Consumer<ThemeModeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp.router(
            title: 'Smart Dental Diagnosis',
            theme: appTheme,
            darkTheme: appThemeDark,
            themeMode: themeNotifier.themeMode,
            locale: themeNotifier.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('tr'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
