import 'package:flutter/material.dart';

import '../../../../app/app_config.dart';
import '../../../../app/theme.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/auth_guard.dart';
import '../../../../core/helpers/helpers.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailOrPhoneController = TextEditingController(
    text: '01700000000',
  );

  final TextEditingController _passwordController = TextEditingController(
    text: '12345678',
  );

  late final ApiClient _apiClient;
  late final LoginController _loginController;

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();

    _loginController = LoginController(
      authRepository: AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSource(
          apiClient: _apiClient,
        ),
      ),
    );

    _loginController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _loginController.removeListener(_onControllerChanged);
    _loginController.dispose();
    _apiClient.close();

    _emailOrPhoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final bool success = await _loginController.login(
      emailOrPhone: _emailOrPhoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      final failure = _loginController.failure;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure?.firstErrorMessage ?? 'Login failed. Please try again.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful.'),
      ),
    );

    await AuthGuard.redirectAfterLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          const _LoginBackgroundShapes(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    const _LoginHeader(),

                    const SizedBox(height: 40),

                    AppCard(
                      padding: const EdgeInsets.all(22),
                      borderRadius: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: _emailOrPhoneController,
                            label: 'Email or Phone',
                            hintText: 'Enter email or phone number',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: ValidationHelper.emailOrPhone,
                          ),

                          const SizedBox(height: 18),

                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Enter password',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: ValidationHelper.password,
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: _loginController.isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
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
                                onPressed: _loginController.isLoading
                                    ? null
                                    : () {
                                        // Later route to forgot password page.
                                      },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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

                          AppButton(
                            text: 'Login',
                            isLoading: _loginController.isLoading,
                            onPressed:
                                _loginController.isLoading ? null : _login,
                          ),

                          const SizedBox(height: 20),

                          const _DividerWithText(text: 'or'),

                          const SizedBox(height: 20),

                          AppButton(
                            text: 'Continue with Google',
                            type: AppButtonType.outline,
                            icon: Icons.g_mobiledata_rounded,
                            onPressed: _loginController.isLoading
                                ? null
                                : () {
                                    // Later Google login implementation.
                                  },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const _EnvironmentInfo(),

                    const SizedBox(height: 20),

                    const _CreateAccountSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
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

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
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
    );
  }
}

class _EnvironmentInfo extends StatelessWidget {
  const _EnvironmentInfo();

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.useMockData) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      showShadow: false,
      backgroundColor: AppColors.accent.withValues(alpha: 0.35),
      borderColor: AppColors.accent,
      child: const Text(
        'Mock login: 01700000000 / 12345678',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
            // Navigator.pushNamed(context, AppRoutes.register);
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