import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://optwidnlfgeehcwmphuv.supabase.co',
    publishableKey: 'sb_publishable_FxpRUUQVGOUJ2yjtNEs_Gw_Viv3VtHB',
  );

  runApp(const StudyCircleApp());
}

class StudyCircleApp extends StatelessWidget {
  const StudyCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroon = Color(0xFF800000);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyCircle',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: maroon,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor:
            Colors.white,

        appBarTheme:
            const AppBarTheme(
          backgroundColor:
              Colors.white,
          foregroundColor:
              maroon,
          elevation: 0,
          surfaceTintColor:
              Colors.transparent,
        ),

        cardTheme:
            CardThemeData(
          color: Colors.white,
          elevation: 1,
          surfaceTintColor:
              Colors.transparent,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              const Color(0xFFF7F7F7),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              color: maroon,
              width: 1.5,
            ),
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                maroon,
            foregroundColor:
                Colors.white,
            elevation: 0,
            minimumSize:
                const Size(
              double.infinity,
              50,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor:
              maroon,
          foregroundColor:
              Colors.white,
        ),

        chipTheme:
            ChipThemeData(
          backgroundColor:
              const Color(0xFFF5F5F5),
          selectedColor:
              maroon,
          side:
              BorderSide.none,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}