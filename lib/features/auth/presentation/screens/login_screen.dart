import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email/phone and password'),
        ),
      );
      return;
    }

    // Later you will call your Go API login endpoint here.
    // Example next route:
    // Navigator.pushReplacementNamed(context, '/home');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login button clicked'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _LoginBackgroundShapes(),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  const _LoginHeader(),

                  const SizedBox(height: 40),

                  _LoginCard(
                    emailOrPhoneController: _emailOrPhoneController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    rememberMe: _rememberMe,
                    onPasswordVisibilityChanged: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onRememberChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    onLogin: _login,
                  ),

                  const SizedBox(height: 28),

                  const _CreateAccountSection(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 44,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Login to manage your family budget',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailOrPhoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onPasswordVisibilityChanged,
    required this.onRememberChanged,
    required this.onLogin,
  });

  final TextEditingController emailOrPhoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onPasswordVisibilityChanged;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email or Phone',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          AppTextField(
            controller: emailOrPhoneController,
            hintText: 'Enter email or phone number',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 18),

          const Text(
            'Password',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          AppTextField(
            controller: passwordController,
            hintText: 'Enter password',
            obscureText: obscurePassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixTap: onPasswordVisibilityChanged,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: rememberMe,
                  activeColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: onRememberChanged,
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'Remember me',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/forgot-password');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.border,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.border,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                // Later you can add Google login here.
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.g_mobiledata_rounded,
                size: 28,
                color: AppColors.primary,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: 22,
              ),
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CreateAccountSection extends StatelessWidget {
  const _CreateAccountSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New to FamilyFund?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),

        TextButton(
          onPressed: () {
            // Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginBackgroundShapes extends StatelessWidget {
  const _LoginBackgroundShapes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -60,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.25),
            ),
          ),
        ),

        Positioned(
          bottom: -90,
          left: -70,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.22),
            ),
          ),
        ),

        Positioned(
          top: 170,
          left: 30,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.6),
            ),
          ),
        ),

        Positioned(
          bottom: 220,
          right: 34,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}