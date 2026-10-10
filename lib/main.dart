import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

bool isPasswordResetScreenOpen = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://optwidnlfgeehcwmphuv.supabase.co',
    publishableKey:
        'sb_publishable_FxpRUUQVGOUJ2yjtNEs_Gw_Viv3VtHB',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen(
    (authState) {
      if (authState.event != AuthChangeEvent.passwordRecovery) {
        return;
      }

      if (isPasswordResetScreenOpen) {
        return;
      }

      isPasswordResetScreenOpen = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = appNavigatorKey.currentState;

        if (navigator == null) {
          isPasswordResetScreenOpen = false;
          return;
        }

        navigator
            .pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
          ),
          (route) => false,
        )
            .whenComplete(() {
          isPasswordResetScreenOpen = false;
        });
      });
    },
  );

  runApp(const StudyCircleApp());
}

class StudyCircleApp extends StatelessWidget {
  const StudyCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroon = Color(0xFF800000);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'StudyCircle',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: maroon,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: maroon,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F7F7),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: maroon,
              width: 1.5,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(
              double.infinity,
              50,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF5F5F5),
          selectedColor: maroon,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}