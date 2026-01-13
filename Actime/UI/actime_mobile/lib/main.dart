import 'package:flutter/material.dart';
import 'screens/landing/landing_not_logged_screen.dart';
// ili
// import 'screens/landing/landing_logged_screen.dart';
// import 'screens/landing/events_list_screen.dart';

void main() {
  runApp(const ActimeApp());
}

class ActimeApp extends StatelessWidget {
  const ActimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D7C8C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7C8C),
        ),
      ),
      home: const LandingPageNotLogged(), // Promijeni za testiranje
    );
  }
}