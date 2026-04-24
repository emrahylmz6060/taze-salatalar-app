import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const SaladApp());
}

class SaladApp extends StatelessWidget {
  const SaladApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A fresh green color
    const Color primaryGreen = Color(0xFF43A047);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Taze Salatalar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryGreen,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryGreen,
            primary: primaryGreen,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAF8),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
