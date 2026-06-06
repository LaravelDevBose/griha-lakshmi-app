import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/budget_action_response_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/budget_response_model.dart';
import '../../data/repositories/budget_repository.dart';

class BudgetController extends ChangeNotifier {
  BudgetController({
    required BudgetRepository repository,
  }) : _repository = repository;

  final BudgetRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  BudgetModel? currentBudget;

  final List<String> defaultCategories = const [
    'Groceries',
    'Medical',
    'Education',
    'Transport',
    'Bills',
    'Rent',
    'Shopping',
    'Others',
  ];

  Future<void> getCurrentBudget() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final BudgetResponseModel response =
          await _repository.getCurrentBudget();

      currentBudget = response.budget;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshBudget() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final BudgetResponseModel response =
          await _repository.getCurrentBudget();

      currentBudget = response.budget;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh budget. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<bool> storeBudget({
    required String month,
    required double totalBudget,
    required int warningPercentage,
    required List<BudgetCategoryModel> categoryBudgets,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final double totalSpent = categoryBudgets.fold(
        0,
        (double sum, BudgetCategoryModel category) =>
            sum + category.spentAmount,
      );

      final BudgetActionResponseModel response =
          await _repository.storeBudget(
        payload: {
          'month': month,
          'total_budget': totalBudget,
          'total_spent': totalSpent,
          'warning_percentage': warningPercentage,
          'category_budgets': categoryBudgets.map(
            (BudgetCategoryModel category) {
              return category.toPayload();
            },
          ).toList(),
        },
      );

      if (response.budget != null) {
        currentBudget = response.budget;
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to save budget. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBudget({
    required int id,
    required String month,
    required double totalBudget,
    required int warningPercentage,
    required List<BudgetCategoryModel> categoryBudgets,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final double totalSpent = categoryBudgets.fold(
        0,
        (double sum, BudgetCategoryModel category) =>
            sum + category.spentAmount,
      );

      final BudgetActionResponseModel response =
          await _repository.updateBudget(
        id: id,
        payload: {
          'month': month,
          'total_budget': totalBudget,
          'total_spent': totalSpent,
          'warning_percentage': warningPercentage,
          'category_budgets': categoryBudgets.map(
            (BudgetCategoryModel category) {
              return category.toPayload();
            },
          ).toList(),
        },
      );

      if (response.budget != null) {
        currentBudget = response.budget;
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update budget. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }
}