import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../organization/organization_profile_screen.dart';
import '../organization/complete_signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        final user = authResponse.user;

        if (user.role == UserRole.organization) {
          if (authResponse.requiresOrganizationSetup) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteSignUpScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OrganizationProfileScreen(),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPageLogged()),
          );
        }
      } else {
        if (response.hasErrors) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Greška pri prijavi'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške. Pokušajte ponovo.'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader('Prijava'),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ActimeTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Unesite email adresu',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.compose([
                            Validators.requiredField('Email'),
                            Validators.email,
                          ]),
                          errorText: _fieldErrors['email'],
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
                        ActimeTextFormField(
                          controller: _passwordController,
                          labelText: 'Lozinka',
                          hintText: 'Unesite lozinku',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignIn(),
                          validator: Validators.requiredField('Lozinka'),
                          errorText: _fieldErrors['password'],
                        ),
                        const SizedBox(height: AppDimensions.spacingXLarge),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.primary,
                              )
                            : ActimePrimaryButton(
                                label: 'Prijavi se',
                                onPressed: _handleSignIn,
                              ),
                        const SizedBox(height: AppDimensions.spacingDefault),
                        ActimeTextButton(
                          label: 'Zaboravljena lozinka?',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.spacingXLarge),
                        _buildSignUpLink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusXLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusXLarge),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Actime',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPageNotLogged()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nemate račun? ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: const Text(
            'Registrujte se',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
