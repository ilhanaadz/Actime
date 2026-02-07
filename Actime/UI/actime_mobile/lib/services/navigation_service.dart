import 'package:flutter/material.dart';

/// Global navigation service
/// Allows navigation from anywhere in the app without BuildContext
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigator?.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic>? navigateToAndClearStack(String routeName, {Object? arguments}) {
    return navigator?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    if (navigator?.canPop() ?? false) {
      navigator?.pop();
    }
  }

  void popUntil(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }
}
