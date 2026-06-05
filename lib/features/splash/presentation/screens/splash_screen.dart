import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../../../../app/app_constants.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _initAnimations();
    _controller.forward();

    _goToNextScreen();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.6,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.2,
        0.8,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _goToNextScreen() {
    Timer(AppConstants.splashDuration, () async {
      if (!mounted) return;

      await AuthGuard.redirectAfterSplash(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundShapes(),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPadding,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: const _LogoWidget(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontSize: screenSize.width < 360 ? 28 : 32,
                                height: 1.2,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: Text(
                          AppConstants.appTagline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _LoadingIndicator(),
                    ),

                    const SizedBox(height: 14),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Preparing your wallet...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                            ),
                      ),
                    ),

                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Center(
        child: CustomPaint(
          size: Size(64, 64),
          painter: _FamilyFundLogoPainter(),
        ),
      ),
    );
  }
}

class _FamilyFundLogoPainter extends CustomPainter {
  const _FamilyFundLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint housePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Path housePath = Path()
      ..moveTo(centerX - 24, centerY + 8)
      ..lineTo(centerX - 24, centerY - 4)
      ..quadraticBezierTo(
        centerX - 24,
        centerY - 16,
        centerX - 12,
        centerY - 20,
      )
      ..lineTo(centerX - 8, centerY - 24)
      ..quadraticBezierTo(
        centerX,
        centerY - 32,
        centerX + 8,
        centerY - 24,
      )
      ..lineTo(centerX + 12, centerY - 20)
      ..quadraticBezierTo(
        centerX + 24,
        centerY - 16,
        centerX + 24,
        centerY - 4,
      )
      ..lineTo(centerX + 24, centerY + 8)
      ..quadraticBezierTo(
        centerX + 24,
        centerY + 14,
        centerX + 18,
        centerY + 14,
      )
      ..lineTo(centerX - 18, centerY + 14)
      ..quadraticBezierTo(
        centerX - 24,
        centerY + 14,
        centerX - 24,
        centerY + 8,
      )
      ..close();

    canvas.drawPath(housePath, housePaint);

    final Paint coinPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY - 2),
      10,
      coinPaint,
    );

    final Paint moneyIconPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, centerY - 8),
      Offset(centerX, centerY + 4),
      moneyIconPaint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX - 3, centerY - 2),
        width: 8,
        height: 10,
      ),
      -pi / 2,
      pi,
      false,
      moneyIconPaint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX + 3, centerY - 2),
        width: 8,
        height: 10,
      ),
      pi / 2,
      pi,
      false,
      moneyIconPaint,
    );

    final Paint familyPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - 14, centerY + 2),
      3,
      familyPaint,
    );

    canvas.drawCircle(
      Offset(centerX + 14, centerY + 2),
      2.5,
      familyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackgroundShapes extends StatelessWidget {
  const _BackgroundShapes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.25),
            ),
          ),
        ),

        Positioned(
          bottom: -80,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.20),
            ),
          ),
        ),

        Positioned(
          top: 120,
          left: 40,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.50),
            ),
          ),
        ),

        Positioned(
          bottom: 160,
          right: 50,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.40),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}