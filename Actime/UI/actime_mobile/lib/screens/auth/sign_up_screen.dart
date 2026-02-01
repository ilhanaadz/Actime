import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../organization/complete_signup_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../landing/landing_not_logged_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isOrganization = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Popunite sva polja')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lozinke se ne podudaraju')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lozinka mora imati najmanje 6 karaktera')),
      );
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
          // Navigate to home for regular users
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPageLogged()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Greška pri registraciji')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Došlo je do greške. Pokušajte ponovo.')),
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
                  child: Column(
                    children: [
                      ActimeTextField(
                        controller: _nameController,
                        hintText: 'Ime i prezime',
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      ActimeTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      ActimeTextField(
                        controller: _passwordController,
                        hintText: 'Lozinka',
                        obscureText: true,
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      ActimeTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Potvrdi lozinku',
                        obscureText: true,
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
