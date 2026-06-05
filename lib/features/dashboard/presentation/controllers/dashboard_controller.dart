import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';

enum DashboardStateStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class DashboardController extends ChangeNotifier {
  DashboardController({
    required DashboardRepository dashboardRepository,
  }) : _dashboardRepository = dashboardRepository;

  final DashboardRepository _dashboardRepository;

  DashboardStateStatus _status = DashboardStateStatus.initial;
  Dashboard? _dashboard;
  Failure? _failure;

  DashboardStateStatus get status => _status;
  Dashboard? get dashboard => _dashboard;
  Failure? get failure => _failure;

  bool get isLoading => _status == DashboardStateStatus.loading;
  bool get isSuccess => _status == DashboardStateStatus.success;
  bool get isEmpty => _status == DashboardStateStatus.empty;
  bool get isError => _status == DashboardStateStatus.error;

  Future<void> loadDashboard() async {
    _status = DashboardStateStatus.loading;
    _failure = null;
    notifyListeners();

    try {
      final Dashboard dashboard = await _dashboardRepository.getDashboard();

      _dashboard = dashboard;
      _status = dashboard.isEmpty
          ? DashboardStateStatus.empty
          : DashboardStateStatus.success;

      notifyListeners();
    } catch (error) {
      _failure = error is ApiException
          ? error.failure
          : ErrorHandler.handle(error);

      ErrorHandler.logError(_failure!);

      _status = DashboardStateStatus.error;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}