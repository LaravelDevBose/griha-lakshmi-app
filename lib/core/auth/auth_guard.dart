import 'package:flutter/material.dart';

import '../../app/router.dart';
import 'token_storage.dart';

class AuthGuard {
  AuthGuard._();

  static Future<bool> isAuthenticated() async {
    return TokenStorage.isLoggedIn();
  }

  static Future<String> getInitialRouteAfterSplash() async {
    final bool isLoggedIn = await isAuthenticated();

    if (isLoggedIn) {
      return AppRoutes.dashboard;
    }

    return AppRoutes.login;
  }

  static Future<void> redirectAfterSplash(BuildContext context) async {
    final String route = await getInitialRouteAfterSplash();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }

  static Future<void> redirectAfterLogin(BuildContext context) async {
    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
    );
  }

  static Future<void> logout(BuildContext context) async {
    await TokenStorage.clearAuthSession();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  static Future<void> protectRoute(BuildContext context) async {
    final bool isLoggedIn = await isAuthenticated();

    if (isLoggedIn) return;

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}