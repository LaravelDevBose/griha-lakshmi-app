import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  Failure? _failure;
  AuthSession? _session;

  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  AuthSession? get session => _session;

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _setLoading(true);
    _failure = null;

    try {
      _session = await _authRepository.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (error) {
      _failure = error is ApiException
          ? error.failure
          : ErrorHandler.handle(error);

      ErrorHandler.logError(_failure!);

      _setLoading(false);
      return false;
    }
  }

  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}