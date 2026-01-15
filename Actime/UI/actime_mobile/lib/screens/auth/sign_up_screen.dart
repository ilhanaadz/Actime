import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../organization/complete_signup_screen.dart';

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
  bool _isOrganization = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_passwordController.text == _confirmPasswordController.text) {
      if (_isOrganization) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompleteSignUpScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
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
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusXLarge),
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
                _buildHeader('Sign Up'),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      ActimeTextField(
                        controller: _nameController,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),
                      ActimeTextField(
                        controller: _emailController,
                        hintText: 'Email',
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),
                      ActimeTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),
                      ActimeTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm password',
                        obscureText: true,
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),
                      _buildOrganizationCheckbox(),
                      const SizedBox(height: AppSizes.spacingXLarge),
                      ActimePrimaryButton(
                        label: 'Sign Up',
                        onPressed: _handleSignUp,
                      ),
                      const SizedBox(height: AppSizes.spacingDefault),
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
          topLeft: Radius.circular(AppSizes.borderRadiusXLarge),
          topRight: Radius.circular(AppSizes.borderRadiusXLarge),
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
            onPressed: () => Navigator.pop(context),
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
          'Sign up as organization',
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
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Sign In',
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
