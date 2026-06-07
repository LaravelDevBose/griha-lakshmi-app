import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/account_action_response_model.dart';
import '../../data/models/account_model.dart';
import '../../data/models/account_response_model.dart';
import '../../data/repositories/account_repository.dart';

class AccountController extends ChangeNotifier {
  AccountController({
    required AccountRepository repository,
  }) : _repository = repository;

  final AccountRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalAccounts = 0;
  int activeAccounts = 0;
  double totalBalance = 0;

  List<AccountModel> accounts = [];

  final List<Map<String, String>> accountTypes = const [
    {'value': 'cash', 'label': 'Cash'},
    {'value': 'bank', 'label': 'Bank'},
    {'value': 'mobile_banking', 'label': 'Mobile Banking'},
    {'value': 'card', 'label': 'Card'},
    {'value': 'wallet', 'label': 'Wallet'},
  ];

  Future<void> getAccounts() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final AccountResponseModel response = await _repository.getAccounts(
        page: currentPage,
        perPage: perPage,
      );

      accounts = response.accounts;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAccounts() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final AccountResponseModel response = await _repository.getAccounts(
        page: currentPage,
        perPage: perPage,
      );

      accounts = response.accounts;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh accounts. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreAccounts() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final AccountResponseModel response = await _repository.getAccounts(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      accounts = [
        ...accounts,
        ...response.accounts,
      ];

      _applySummary(response);
    } catch (_) {
      // Keep current list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeAccount({
    required String accountName,
    required String accountType,
    required String institutionName,
    required String accountNumberLastFour,
    required double openingBalance,
    required double currentBalance,
    required String currency,
    required bool isDefault,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final AccountActionResponseModel response =
          await _repository.storeAccount(
        payload: {
          'account_name': accountName,
          'account_type': accountType,
          'institution_name': institutionName,
          'account_number_last_four': accountNumberLastFour,
          'opening_balance': openingBalance,
          'current_balance': currentBalance,
          'currency': currency,
          'is_default': isDefault,
          'status': 'active',
          'notes': notes,
        },
      );

      if (response.account != null) {
        if (response.account!.isDefault) {
          accounts = accounts.map((AccountModel account) {
            return account.copyWith(isDefault: false);
          }).toList();
        }

        accounts = [
          response.account!,
          ...accounts,
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
      errorMessage = 'Unable to save account. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateAccount({
    required int id,
    required String accountName,
    required String accountType,
    required String institutionName,
    required String accountNumberLastFour,
    required double openingBalance,
    required double currentBalance,
    required String currency,
    required bool isDefault,
    required String status,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final AccountActionResponseModel response =
          await _repository.updateAccount(
        id: id,
        payload: {
          'account_name': accountName,
          'account_type': accountType,
          'institution_name': institutionName,
          'account_number_last_four': accountNumberLastFour,
          'opening_balance': openingBalance,
          'current_balance': currentBalance,
          'currency': currency,
          'is_default': isDefault,
          'status': status,
          'notes': notes,
        },
      );

      if (response.account != null) {
        accounts = accounts.map((AccountModel account) {
          if (response.account!.isDefault) {
            account = account.copyWith(isDefault: false);
          }

          if (account.id == id) {
            return response.account!;
          }

          return account;
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
      errorMessage = 'Unable to update account. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> deactivateAccount(int id) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final AccountActionResponseModel response =
          await _repository.deactivateAccount(id: id);

      accounts = accounts.map((AccountModel account) {
        if (account.id == id) {
          return account.copyWith(
            status: 'inactive',
            isDefault: false,
          );
        }

        return account;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to deactivate account. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> setDefaultAccount(int id) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final AccountActionResponseModel response =
          await _repository.setDefaultAccount(id: id);

      accounts = accounts.map((AccountModel account) {
        return account.copyWith(
          isDefault: account.id == id,
        );
      }).toList();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update default account. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  String accountTypeLabel(String value) {
    final Map<String, String> matched = accountTypes.firstWhere(
      (Map<String, String> item) => item['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );

    return matched['label'] ?? value;
  }

  void _applySummary(AccountResponseModel response) {
    totalAccounts = response.summary.totalAccounts;
    activeAccounts = response.summary.activeAccounts;
    totalBalance = response.summary.totalBalance;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalAccounts = accounts.length;

    activeAccounts = accounts
        .where((AccountModel account) => account.isActive)
        .length;

    totalBalance = accounts.fold(
      0,
      (double sum, AccountModel account) {
        if (!account.isActive) return sum;
        return sum + account.currentBalance;
      },
    );
  }
}