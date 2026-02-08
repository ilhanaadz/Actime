import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/landing/landing_not_logged_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env for BASE_URL or fallback
  await dotenv.load(fileName: ".env");

  // Stripe publishable key: try dart-define first, fallback to .env, fallback to dummy
  final stripeKeyFromDefine = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  final stripeKey = stripeKeyFromDefine.isNotEmpty
      ? stripeKeyFromDefine
      : dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_YOUR_KEY_HERE';

  Stripe.publishableKey = stripeKey;

  runApp(const ActimeApp());
}

class ActimeApp extends StatelessWidget {
  const ActimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService().navigatorKey,
      title: 'Actime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D7C8C),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D7C8C)),
      ),
      routes: {
        '/': (context) => const LandingPageNotLogged(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle email confirmation route
        if (settings.name?.startsWith('/confirm-email') ?? false) {
          final uri = Uri.parse(settings.name!);
          final userId = uri.queryParameters['userId'] ?? '';
          final token = uri.queryParameters['token'] ?? '';

          if (userId.isNotEmpty && token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                userId: userId,
                token: Uri.decodeComponent(token),
              ),
            );
          }
        }

        // Handle password reset route
        if (settings.name?.startsWith('/reset-password') ?? false) {
          final uri = Uri.parse(settings.name!);
          final email = uri.queryParameters['email'] ?? '';
          final token = uri.queryParameters['token'] ?? '';

          if (email.isNotEmpty && token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: email,
                token: Uri.decodeComponent(token),
              ),
            );
          }
        }

        // Default route
        return null;
      },
    );
  }
}
