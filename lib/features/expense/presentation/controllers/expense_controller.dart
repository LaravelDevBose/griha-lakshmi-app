import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/expense_action_response_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/expense_response_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseController extends ChangeNotifier {
  ExpenseController({
    required ExpenseRepository repository,
  }) : _repository = repository;

  final ExpenseRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;
  bool isDeleting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  double totalExpense = 0;
  List<ExpenseModel> expenses = [];

  final List<String> categories = const [
    'Grocery',
    'Utility',
    'Health',
    'Transport',
    'Food',
    'Education',
    'Home',
    'Shopping',
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

  Future<void> getExpenses() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final ExpenseResponseModel response = await _repository.getExpenses(
        page: currentPage,
        perPage: perPage,
      );

      expenses = response.expenses;
      totalExpense = response.summary.totalExpense;
      hasMorePages = response.pagination.hasMorePages;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshExpenses() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final ExpenseResponseModel response = await _repository.getExpenses(
        page: currentPage,
        perPage: perPage,
      );

      expenses = response.expenses;
      totalExpense = response.summary.totalExpense;
      hasMorePages = response.pagination.hasMorePages;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh expense list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreExpenses() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final ExpenseResponseModel response = await _repository.getExpenses(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      totalExpense = response.summary.totalExpense;
      expenses = [
        ...expenses,
        ...response.expenses,
      ];
      hasMorePages = response.pagination.hasMorePages;
    } catch (_) {
      // Keep existing list visible if pagination fails.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeExpense({
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required String paymentAccount,
    required DateTime date,
    required List<String> receiptImages,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ExpenseActionResponseModel response =
          await _repository.storeExpense(
        payload: {
          'title': title,
          'amount': amount,
          'category': category,
          'paid_by': paidBy,
          'payment_account': paymentAccount,
          'date': date.toIso8601String(),
          'receipt_images': receiptImages,
          'notes': notes,
        },
      );

      if (response.expense != null) {
        expenses = [
          response.expense!,
          ...expenses,
        ];
        totalExpense += response.expense!.amount;
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to save expense. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required String paymentAccount,
    required DateTime date,
    required List<String> receiptImages,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ExpenseModel? oldExpense = _findExpenseById(id);

      final ExpenseActionResponseModel response =
          await _repository.updateExpense(
        id: id,
        payload: {
          'title': title,
          'amount': amount,
          'category': category,
          'paid_by': paidBy,
          'payment_account': paymentAccount,
          'date': date.toIso8601String(),
          'receipt_images': receiptImages,
          'notes': notes,
        },
      );

      if (response.expense != null) {
        expenses = expenses.map((ExpenseModel item) {
          if (item.id == id) {
            return response.expense!;
          }

          return item;
        }).toList();

        if (oldExpense != null) {
          totalExpense =
              totalExpense - oldExpense.amount + response.expense!.amount;
        }
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update expense. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteExpense(int id) async {
    isDeleting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ExpenseModel? deletedExpense = _findExpenseById(id);

      final ExpenseActionResponseModel response =
          await _repository.deleteExpense(id: id);

      expenses = expenses.where((ExpenseModel item) => item.id != id).toList();

      if (deletedExpense != null) {
        totalExpense -= deletedExpense.amount;
      }

      successMessage = response.message;
      isDeleting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to delete expense. Please try again.';
    }

    isDeleting = false;
    notifyListeners();
    return false;
  }

  ExpenseModel? _findExpenseById(int id) {
    for (final ExpenseModel expense in expenses) {
      if (expense.id == id) {
        return expense;
      }
    }

    return null;
  }
}