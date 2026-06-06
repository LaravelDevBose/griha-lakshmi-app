import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/savings_goal_action_response_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/models/savings_goal_response_model.dart';
import '../../data/repositories/savings_goal_repository.dart';

class SavingsGoalController extends ChangeNotifier {
  SavingsGoalController({
    required SavingsGoalRepository repository,
  }) : _repository = repository;

  final SavingsGoalRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalGoals = 0;
  int activeGoals = 0;
  int completedGoals = 0;
  double targetTotal = 0;
  double currentTotal = 0;
  double monthlyTargetTotal = 0;

  List<SavingsGoalModel> savingsGoals = [];

  final List<String> goalTypes = const [
    'Emergency',
    'Travel',
    'Education',
    'Home',
    'Electronics',
    'Health',
    'Wedding',
    'Other',
  ];

  final List<String> members = const [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Self',
  ];

  final List<String> accounts = const [
    'Cash',
    'DBBL Bank',
    'bKash',
    'Nagad',
    'Card',
  ];

  Future<void> getSavingsGoals() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final SavingsGoalResponseModel response =
          await _repository.getSavingsGoals(
        page: currentPage,
        perPage: perPage,
      );

      savingsGoals = response.savingsGoals;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshSavingsGoals() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final SavingsGoalResponseModel response =
          await _repository.getSavingsGoals(
        page: currentPage,
        perPage: perPage,
      );

      savingsGoals = response.savingsGoals;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh savings goal list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreSavingsGoals() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final SavingsGoalResponseModel response =
          await _repository.getSavingsGoals(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;

      savingsGoals = [
        ...savingsGoals,
        ...response.savingsGoals,
      ];

      _applySummary(response);
    } catch (_) {
      // Keep current list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeSavingsGoal({
    required String goalName,
    required String goalType,
    required double targetAmount,
    required double currentAmount,
    required double monthlyDepositTarget,
    required int depositDueDay,
    required DateTime targetDate,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final SavingsGoalActionResponseModel response =
          await _repository.storeSavingsGoal(
        payload: {
          'goal_name': goalName,
          'goal_type': goalType,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          'monthly_deposit_target': monthlyDepositTarget,
          'deposit_due_day': depositDueDay,
          'target_date': targetDate.toIso8601String(),
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': currentAmount >= targetAmount ? 'completed' : 'active',
          'notes': notes,
        },
      );

      if (response.savingsGoal != null) {
        savingsGoals = [
          response.savingsGoal!,
          ...savingsGoals,
        ];
        _recalculateLocalSummary();
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to save savings goal. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateSavingsGoal({
    required int id,
    required String goalName,
    required String goalType,
    required double targetAmount,
    required double currentAmount,
    required double monthlyDepositTarget,
    required int depositDueDay,
    required DateTime targetDate,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final SavingsGoalActionResponseModel response =
          await _repository.updateSavingsGoal(
        id: id,
        payload: {
          'goal_name': goalName,
          'goal_type': goalType,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          'monthly_deposit_target': monthlyDepositTarget,
          'deposit_due_day': depositDueDay,
          'target_date': targetDate.toIso8601String(),
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': currentAmount >= targetAmount ? 'completed' : 'active',
          'notes': notes,
        },
      );

      if (response.savingsGoal != null) {
        savingsGoals = savingsGoals.map((SavingsGoalModel goal) {
          if (goal.id == id) {
            return response.savingsGoal!;
          }

          return goal;
        }).toList();

        _recalculateLocalSummary();
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update savings goal. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> recordDeposit({
    required int id,
    required double depositAmount,
    required String account,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final SavingsGoalActionResponseModel response =
          await _repository.recordDeposit(
        id: id,
        depositAmount: depositAmount,
        account: account,
      );

      savingsGoals = savingsGoals.map((SavingsGoalModel goal) {
        if (goal.id == id) {
          final double updatedAmount = goal.currentAmount + depositAmount;
          final double safeAmount = updatedAmount > goal.targetAmount
              ? goal.targetAmount
              : updatedAmount;

          return goal.copyWith(
            currentAmount: safeAmount,
            status: safeAmount >= goal.targetAmount ? 'completed' : 'active',
          );
        }

        return goal;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to record deposit. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  void _applySummary(SavingsGoalResponseModel response) {
    totalGoals = response.summary.totalGoals;
    activeGoals = response.summary.activeGoals;
    completedGoals = response.summary.completedGoals;
    targetTotal = response.summary.targetTotal;
    currentTotal = response.summary.currentTotal;
    monthlyTargetTotal = response.summary.monthlyTargetTotal;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalGoals = savingsGoals.length;

    activeGoals = savingsGoals
        .where((SavingsGoalModel goal) => goal.isActive)
        .length;

    completedGoals = savingsGoals
        .where((SavingsGoalModel goal) => goal.isCompleted)
        .length;

    targetTotal = savingsGoals.fold(
      0,
      (double sum, SavingsGoalModel goal) => sum + goal.targetAmount,
    );

    currentTotal = savingsGoals.fold(
      0,
      (double sum, SavingsGoalModel goal) => sum + goal.currentAmount,
    );

    monthlyTargetTotal = savingsGoals.fold(
      0,
      (double sum, SavingsGoalModel goal) => sum + goal.monthlyDepositTarget,
    );
  }
}