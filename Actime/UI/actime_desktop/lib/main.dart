import 'package:flutter/material.dart';
import 'screens/admin_login_screen.dart';

void main() {
  runApp(const ActimeAdminApp());
}

class ActimeAdminApp extends StatelessWidget {
  const ActimeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actime Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D7C8C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7C8C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'SF Pro Display',
      ),
      home: const AdminLoginScreen(),
    );
  }
}