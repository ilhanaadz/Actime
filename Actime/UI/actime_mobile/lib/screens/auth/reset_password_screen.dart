import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        email: widget.email,
        token: widget.token,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      final response = await _authService.resetPassword(request);

      if (!mounted) return;

      if (response.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Uspješno!'),
              ],
            ),
            content: const Text(
              'Vaša lozinka je uspješno promijenjena. Sada se možete prijaviti s novom lozinkom.',
            ),
            actions: [
              ActimePrimaryButton(
                label: 'Prijavite se',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Link za resetiranje lozinke je nevažeći ili je istekao',
            ),
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
        setState(() => _isLoading = false);
      }
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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
                    'Resetirajte lozinku',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),

                  // Email info
                  Text(
                    'Resetiranje lozinke za: ${widget.email}',
                    style: const TextStyle(
                      fontSize: 14,
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
                        // New password
                        ActimeTextFormField(
                          controller: _passwordController,
                          labelText: 'Nova lozinka',
                          hintText: 'Unesite novu lozinku',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: Validators.compose([
                            Validators.requiredField('Nova lozinka'),
                            Validators.minLengthField(6, 'Nova lozinka'),
                          ]),
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),

                        // Confirm password
                        ActimeTextFormField(
                          controller: _confirmPasswordController,
                          labelText: 'Potvrdite lozinku',
                          hintText: 'Potvrdite novu lozinku',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                          validator: (value) {
                            final required = Validators.requiredField('Potvrda lozinke')(value);
                            if (required != null) return required;

                            if (value != _passwordController.text) {
                              return 'Lozinke se ne podudaraju';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleSubmit(),
                        ),
                        const SizedBox(height: AppDimensions.spacingXLarge),

                        // Submit button
                        ActimePrimaryButton(
                          label: 'Resetiraj lozinku',
                          onPressed: _isLoading ? null : _handleSubmit,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMedium),

                        // Back to login
                        ActimeTextButton(
                          label: 'Povratak na prijavu',
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
