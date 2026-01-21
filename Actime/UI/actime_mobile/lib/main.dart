import 'package:flutter/material.dart';
import 'screens/landing/landing_not_logged_screen.dart';
import 'screens/landing/landing_logged_screen.dart';
import 'screens/organization/my_events_org_screen.dart';
import 'screens/organization/people_org_screen.dart';

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
      // Promijeni za testiranje:
      // - LandingPageNotLogged() - za nelogovane korisnike
      // - LandingPageLogged() - za logovane korisnike
      // - MyEventsOrgScreen(organizationId: '1') - za organizaciju (my events)
      // - PeopleOrgScreen(organizationId: '1') - za organizaciju (people tab)
      home: const LandingPageNotLogged(),
    );
  }
}