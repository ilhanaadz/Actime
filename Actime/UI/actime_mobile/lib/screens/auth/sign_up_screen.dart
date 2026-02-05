import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';
import '../organization/complete_signup_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import 'email_confirmation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isOrganization = false;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _isOrganization ? UserRole.organization : UserRole.user,
      );

      final response = await _authService.register(request);

      if (!mounted) return;

      if (response.success && response.data != null) {
        if (_isOrganization) {
          // Navigate to complete organization signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompleteSignUpScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailConfirmationScreen(
                email: _emailController.text.trim(),
                isPasswordReset: false,
              ),
            ),
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
              content: Text(response.message ?? 'Greška pri registraciji'),
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
                _buildHeader('Registracija'),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ActimeTextFormField(
                          controller: _nameController,
                          labelText: 'Ime i prezime',
                          hintText: 'Unesite ime i prezime',
                          textInputAction: TextInputAction.next,
                          validator: Validators.compose([
                            Validators.requiredField('Ime i prezime'),
                            Validators.minLengthField(2, 'Ime i prezime'),
                          ]),
                          errorText: _fieldErrors['username'],
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
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
                          hintText: 'Unesite lozinku (min. 6 znakova)',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: Validators.compose([
                            Validators.requiredField('Lozinka'),
                            Validators.minLengthField(6, 'Lozinka'),
                          ]),
                          errorText: _fieldErrors['password'],
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
                        ActimeTextFormField(
                          controller: _confirmPasswordController,
                          labelText: 'Potvrdi lozinku',
                          hintText: 'Ponovite lozinku',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignUp(),
                          validator: (value) {
                            final requiredError = Validators.required(value, 'Potvrda lozinke');
                            if (requiredError != null) return requiredError;
                            return Validators.match(value, _passwordController.text, 'Lozinke');
                          },
                          errorText: _fieldErrors['confirmPassword'],
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
                        _buildOrganizationCheckbox(),
                        const SizedBox(height: AppDimensions.spacingXLarge),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.primary,
                              )
                            : ActimePrimaryButton(
                                label: 'Registruj se',
                                onPressed: _handleSignUp,
                              ),
                        const SizedBox(height: AppDimensions.spacingDefault),
                        _buildSignInLink(),
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

  Widget _buildOrganizationCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isOrganization,
          onChanged: (value) {
            setState(() {
              _isOrganization = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        const Text(
          'Registruj se kao organizacija',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Već imate račun? ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Prijavite se',
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
