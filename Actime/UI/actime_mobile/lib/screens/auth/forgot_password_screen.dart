import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import 'email_confirmation_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      await _authService.forgotPassword(email);

      if (!mounted) return;

      // Always show success (for security - don't reveal if email exists)
      // Navigate to email confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailConfirmationScreen(
            email: email,
            isPasswordReset: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške. Pokušajte ponovo.'),
          backgroundColor: AppColors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Title
                  const Text(
                    'Zaboravljena lozinka?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Description
                  const Text(
                    'Unesite vašu email adresu i poslat ćemo vam link za resetiranje lozinke.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ActimeTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'vas.email@primjer.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.compose([
                            Validators.requiredField('Email'),
                            Validators.email,
                          ]),
                          onFieldSubmitted: (_) => _handleSubmit(),
                        ),
                        const SizedBox(height: AppDimensions.spacingXLarge),

                        // Submit button
                        ActimePrimaryButton(
                          label: 'Pošalji link',
                          onPressed: _isLoading ? null : _handleSubmit,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMedium),

                        // Back to login
                        ActimeTextButton(
                          label: 'Povratak na prijavu',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
