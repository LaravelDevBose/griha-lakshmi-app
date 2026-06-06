import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/income_action_response_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/income_response_model.dart';
import '../../data/repositories/income_repository.dart';

class IncomeController extends ChangeNotifier {
  IncomeController({
    required IncomeRepository repository,
  }) : _repository = repository;

  final IncomeRepository _repository;

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

  double totalIncome = 0;
  List<IncomeModel> incomes = [];

  final List<String> categories = const [
    'Salary',
    'Tuition',
    'Freelance',
    'Bonus',
    'Family Fund',
    'Business',
    'Gift',
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

  Future<void> getIncomes() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final IncomeResponseModel response = await _repository.getIncomes(
        page: currentPage,
        perPage: perPage,
      );

      incomes = response.incomes;
      totalIncome = response.summary.totalIncome;
      hasMorePages = response.pagination.hasMorePages;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshIncomes() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final IncomeResponseModel response = await _repository.getIncomes(
        page: currentPage,
        perPage: perPage,
      );

      incomes = response.incomes;
      totalIncome = response.summary.totalIncome;
      hasMorePages = response.pagination.hasMorePages;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh income list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreIncomes() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final IncomeResponseModel response = await _repository.getIncomes(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      totalIncome = response.summary.totalIncome;
      incomes = [
        ...incomes,
        ...response.incomes,
      ];
      hasMorePages = response.pagination.hasMorePages;
    } catch (_) {
      // Keep current list visible if next page fails.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeIncome({
    required String title,
    required double amount,
    required String category,
    required String receivedBy,
    required String account,
    required DateTime date,
    required bool isRecurring,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final IncomeActionResponseModel response = await _repository.storeIncome(
        payload: {
          'title': title,
          'amount': amount,
          'category': category,
          'received_by': receivedBy,
          'account': account,
          'date': date.toIso8601String(),
          'is_recurring': isRecurring,
          'notes': notes,
        },
      );

      if (response.income != null) {
        incomes = [
          response.income!,
          ...incomes,
        ];
        totalIncome += response.income!.amount;
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to save income. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateIncome({
    required int id,
    required String title,
    required double amount,
    required String category,
    required String receivedBy,
    required String account,
    required DateTime date,
    required bool isRecurring,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final IncomeModel? oldIncome = _findIncomeById(id);

      final IncomeActionResponseModel response = await _repository.updateIncome(
        id: id,
        payload: {
          'title': title,
          'amount': amount,
          'category': category,
          'received_by': receivedBy,
          'account': account,
          'date': date.toIso8601String(),
          'is_recurring': isRecurring,
          'notes': notes,
        },
      );

      if (response.income != null) {
        incomes = incomes.map((IncomeModel item) {
          if (item.id == id) {
            return response.income!;
          }

          return item;
        }).toList();

        if (oldIncome != null) {
          totalIncome = totalIncome - oldIncome.amount + response.income!.amount;
        }
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update income. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteIncome(int id) async {
    isDeleting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final IncomeModel? deletedIncome = _findIncomeById(id);

      final IncomeActionResponseModel response =
          await _repository.deleteIncome(id: id);

      incomes = incomes.where((IncomeModel item) => item.id != id).toList();

      if (deletedIncome != null) {
        totalIncome -= deletedIncome.amount;
      }

      successMessage = response.message;
      isDeleting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to delete income. Please try again.';
    }

    isDeleting = false;
    notifyListeners();
    return false;
  }

  IncomeModel? _findIncomeById(int id) {
    for (final IncomeModel income in incomes) {
      if (income.id == id) {
        return income;
      }
    }

    return null;
  }
}