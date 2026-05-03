import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crops_screen.dart';
import 'screens/market_screen.dart';
import 'screens/profile_screen.dart';

import 'widgets/bottom_navbar.dart';

import 'api/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

// 🌍 Localization
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('languageCode') ?? 'en';

  final loginService = LoginService();
  final isLoggedIn = await loginService.isLoggedIn();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(Locale(langCode)),
      child: NeuralFieldApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class NeuralFieldApp extends StatelessWidget {
  final bool isLoggedIn;

  const NeuralFieldApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NeuralField',

          // 🔥 FIX 1: Stable Theme (prevents red flash)
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF5F7F3),

            // Remove splash flash
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7F3),
              elevation: 0,
              centerTitle: false,
            ),

            // 🔥 Smooth transitions
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          // 🌍 LANGUAGE
          locale: localeProvider.locale,

          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('mr'),
          ],

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 🔥 KEEP LOGIN FLOW
          home: isLoggedIn ? const MainScreen() : const LoginScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CropsScreen(),
    MarketScreen(),
    ProfileScreen(),
  ];

  void onTabChange(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 FIX 2: Prevent blank flicker frame
      backgroundColor: const Color(0xFFF5F7F3),

      body: IndexedStack( // 👈 VERY IMPORTANT FIX
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: onTabChange,
      ),
    );
  }
}