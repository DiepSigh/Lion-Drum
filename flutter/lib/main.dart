import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'l10n/app_localizations.dart';

const _localePreferenceKey = 'selected_locale_code';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = _localeFromCode(prefs.getString(_localePreferenceKey));
  await MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(LionDanceKitApp(initialLocale: savedLocale));
}

class LionDanceKitApp extends StatefulWidget {
  const LionDanceKitApp({required this.initialLocale, super.key});

  final Locale initialLocale;

  @override
  State<LionDanceKitApp> createState() => _LionDanceKitAppState();
}

class _LionDanceKitAppState extends State<LionDanceKitApp> {
  late Locale _locale = widget.initialLocale;

  Future<void> _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, locale.languageCode);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(locale: _locale, onLocaleChanged: _setLocale),
    );
  }
}

Locale _localeFromCode(String? code) {
  switch (code) {
    case 'zh':
      return const Locale('zh');
    case 'vi':
      return const Locale('vi');
    default:
      return const Locale('en');
  }
}
