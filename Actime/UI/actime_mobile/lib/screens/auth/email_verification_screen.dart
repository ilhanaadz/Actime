import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../models/models.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userId;
  final String token;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isVerifying = true;
  bool _isSuccess = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      final request = ConfirmEmailRequest(
        userId: widget.userId,
        token: widget.token,
      );

      final response = await _authService.confirmEmail(request);

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _isSuccess = response.success;
        _message = response.message ??
            (response.success
                ? 'Email je uspješno potvrđen! Možete se prijaviti.'
                : 'Link za potvrdu je nevažeći ili je istekao.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _isSuccess = false;
        _message = 'Došlo je do greške. Pokušajte ponovo.';
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                  if (_isVerifying)
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? Colors.green.shade50
                            : AppColors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        size: 40,
                        color: _isSuccess ? Colors.green.shade700 : AppColors.red,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Title
                  Text(
                    _isVerifying
                        ? 'Potvrđivanje emaila...'
                        : _isSuccess
                            ? 'Email potvrđen!'
                            : 'Potvrda nije uspjela',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Message
                  if (!_isVerifying)
                    Text(
                      _message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: AppDimensions.spacingXLarge),

                  // Actions
                  if (!_isVerifying) ...[
                    if (_isSuccess)
                      ActimePrimaryButton(
                        label: 'Prijavite se',
                        onPressed: _navigateToLogin,
                      )
                    else ...[
                      ActimePrimaryButton(
                        label: 'Pokušaj ponovo',
                        onPressed: _verifyEmail,
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      ActimeTextButton(
                        label: 'Povratak na prijavu',
                        onPressed: _navigateToLogin,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
