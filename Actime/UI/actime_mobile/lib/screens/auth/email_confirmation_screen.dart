import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _authService = AuthService();
  bool _isResending = false;
  bool _emailSent = false;

  Future<void> _handleResendEmail() async {
    setState(() => _isResending = true);

    try {
      final response = widget.isPasswordReset
          ? await _authService.forgotPassword(widget.email)
          : await _authService.resendConfirmationEmail(widget.email);

      if (!mounted) return;

      if (response.success) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email je ponovo poslan'),
            backgroundColor: Colors.green.shade600,
          ),
        );

        // Reset message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _emailSent = false);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri slanju emaila'),
            backgroundColor: AppColors.red,
          ),
        );
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
        setState(() => _isResending = false);
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
            constraints: const BoxConstraints(maxWidth: 500),
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
              padding: const EdgeInsets.all(40.0),
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
                      Icons.email_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Title
                  Text(
                    widget.isPasswordReset
                        ? 'Provjerite email'
                        : 'Potvrdite email',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Description
                  Text(
                    widget.isPasswordReset
                        ? 'Poslali smo vam link za resetiranje lozinke na:'
                        : 'Poslali smo vam link za potvrdu na:',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),

                  // Email
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.isPasswordReset
                                ? 'Kliknite na link u emailu da biste resetirali lozinku. Link je važeći 1 sat.'
                                : 'Kliknite na link u emailu da biste potvrdili vašu email adresu. Link je važeći 24 sata.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Success message after resend
                  if (_emailSent)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLarge),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Email je ponovo poslan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Resend button
                  ActimeTextButton(
                    label: 'Niste primili email? Pošaljite ponovo',
                    onPressed: _isResending ? null : _handleResendEmail,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Back to login
                  ActimeOutlinedButton(
                    label: 'Povratak na prijavu',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
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
