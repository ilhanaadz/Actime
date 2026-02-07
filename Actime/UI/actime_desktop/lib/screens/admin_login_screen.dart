import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  Map<String, String> _fieldErrors = {};
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        // Check if user has Admin role
        if (response.data!.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          await _authService.logout();
          _showError('Pristup odbijen. Nalog nije validan.');
        }
      } else {
        if (response.errors != null && response.errors!.isNotEmpty) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
         _showError(response.message ?? 'Prijava nije uspjela. Provjerite podatke.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Greška pri povezivanju. Provjerite internet vezu.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(AppDimensions.paddingXXXL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                        vertical: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: const Text(
                        'Actime',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Welcome Text
                  const Center(
                    child: Text(
                      'Welcome to Actime',
                      style: AppTextStyles.heading1,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  Center(
                    child: Text(
                      'Sign in to continue',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Form with validation
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Unesite email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.compose([
                            Validators.requiredField('Email'),
                            Validators.email,
                          ]),
                          errorText: _fieldErrors['email'],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            if (_fieldErrors['email'] != null) {
                              setState(() => _fieldErrors.remove('email'));
                            }
                          },
                        ),

                        const SizedBox(height: AppDimensions.spacingXL),

                        // Password Field
                        AppTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Unesite lozinku',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: Validators.requiredField('Lozinka'),
                          errorText: _fieldErrors['password'],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (_) {
                            if (!_isLoading) _handleLogin();
                          },
                          onChanged: (value) {
                            if (_fieldErrors['password'] != null) {
                              setState(() => _fieldErrors.remove('password'));
                            }
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.grey600,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXXL),

                        // Sign In Button
                        AppButton(
                          text: _isLoading ? 'Signing In...' : 'Sign In',
                          onPressed: _isLoading ? null : _handleLogin,
                          fullWidth: true,
                          size: AppButtonSize.large,
                          isLoading: _isLoading,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
