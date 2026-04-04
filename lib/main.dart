import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indikom_app/features/home/bloc/home_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/hive_keys.dart';
import 'core/l10n/app_localizations.dart';
import 'config/routing/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/language_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final authBox = await Hive.openBox(HiveKeys.authBox);
  final settingsBox = await Hive.openBox(HiveKeys.settingsBox);

  // ✅ Create instances ONCE
  final languageBloc = LanguageBloc(settingsBox: settingsBox)
    ..add(LoadLanguageEvent());
  final authBloc = AuthBloc(authBox: authBox); // ✅ Fixed: pass authBox

  // ✅ Initialize router ONCE
  AppRouter().initialize();

  runApp(MyApp(
    settingsBox: settingsBox,
    languageBloc: languageBloc,
    authBloc: authBloc,
  ));
}

class MyApp extends StatelessWidget {
  final Box settingsBox;
  final LanguageBloc languageBloc;
  final AuthBloc authBloc;

  const MyApp({
    super.key,
    required this.settingsBox,
    required this.languageBloc,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider.value(value: languageBloc),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          final locale =
              state is LanguageLoaded ? state.locale : const Locale('en');
          final textDirection =
              state is LanguageLoaded ? state.textDirection : TextDirection.ltr;

          return MaterialApp.router(
            title: 'IndiKom',
            debugShowCheckedModeBanner: false,

            // Localization
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ✅ RTL Support
            builder: (context, child) {
              return Directionality(
                textDirection: textDirection,
                child: child ?? const SizedBox(),
              );
            },

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            // ✅ Use SAME router instance
            routerConfig: AppRouter().router,
          );
        },
      ),
    );
  }
}
