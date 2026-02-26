import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/app_localizations.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/connectivity_wrapper.dart';
import 'presentation/bloc/restaurant_bloc.dart';
import 'presentation/bloc/category_bloc.dart';
import 'presentation/bloc/settings_bloc.dart';
import 'presentation/pages/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Faqat Portrait rejimida ishlash
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,

    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final locationService = LocationService();
  final connectivityService = ConnectivityService();

  runApp(MyApp(
    prefs: prefs,
    locationService: locationService,
    connectivityService: connectivityService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LocationService locationService;
  final ConnectivityService connectivityService;

  const MyApp({
    super.key,
    required this.prefs,
    required this.locationService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingsBloc(prefs: prefs)..add(LoadSettings()),
        ),
        BlocProvider(
          create: (context) => RestaurantBloc(),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(),
        ),
      ],
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Til o'zgarganda restoranlar va kategoriyalarni qayta yuklash
          context.read<RestaurantBloc>().add(
            LoadRestaurants(language: state.apiLanguage),
          );
          context.read<CategoryBloc>().add(
            LoadCategories(language: state.apiLanguage),
          );
        },
        builder: (context, state) {
          final materialLocale = state.languageCode == 'kaa'
              ? const Locale('uz')
              : state.locale;

          return MaterialApp(
            title: 'Gastronomic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: materialLocale,
            supportedLocales: const [
              Locale('uz'),
              Locale('ru'),
              Locale('en'),
            ],
            localizationsDelegates: [
              _CustomLocalizationsDelegate(state.languageCode),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('uz');
            },
            home: ConnectivityWrapper(
              connectivityService: connectivityService,
              child: SplashScreen(
                prefs: prefs,
                locationService: locationService,
                connectivityService: connectivityService,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final String languageCode;

  const _CustomLocalizationsDelegate(this.languageCode);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(Locale(languageCode));
  }

  @override
  bool shouldReload(_CustomLocalizationsDelegate old) => old.languageCode != languageCode;
}