import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_response_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  TransactionController({
    required TransactionRepository repository,
  }) : _repository = repository;

  final TransactionRepository _repository;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  TransactionSummaryModel? summary;
  List<TransactionModel> transactions = [];

  String selectedCategory = 'All';
  String selectedMember = 'All';
  String selectedAccount = 'All';
  String selectedType = 'All';

  DateTimeRange? selectedDateRange;

  Future<void> getTransactions() async {
    isLoading = true;
    errorMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final TransactionResponseModel response =
          await _repository.getTransactions(
        page: currentPage,
        perPage: perPage,
      );

      summary = response.summary;
      transactions = response.transactions;
      hasMorePages = response.pagination.hasMorePages;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreTransactions() async {
    if (isLoading || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final TransactionResponseModel response =
          await _repository.getTransactions(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      summary = response.summary;
      transactions = [
        ...transactions,
        ...response.transactions,
      ];
      hasMorePages = response.pagination.hasMorePages;
    } catch (_) {
      // We do not block the existing list if next page fails.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((TransactionModel transaction) {
      final bool matchCategory = selectedCategory == 'All' ||
          transaction.category == selectedCategory;

      final bool matchMember =
          selectedMember == 'All' || transaction.member == selectedMember;

      final bool matchAccount =
          selectedAccount == 'All' || transaction.account == selectedAccount;

      final bool matchType = selectedType == 'All' ||
          transaction.type.name.toLowerCase() == selectedType.toLowerCase();

      final bool matchDateRange = selectedDateRange == null ||
          transaction.date.isAfter(
                selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              transaction.date.isBefore(
                selectedDateRange!.end.add(const Duration(days: 1)),
              );

      return matchCategory &&
          matchMember &&
          matchAccount &&
          matchType &&
          matchDateRange;
    }).toList();
  }

  double get totalIncome {
    return filteredTransactions
        .where((TransactionModel item) => item.isIncome)
        .fold(0, (double sum, TransactionModel item) => sum + item.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((TransactionModel item) => item.isExpense)
        .fold(0, (double sum, TransactionModel item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  List<String> get categories {
    return [
      'All',
      ...transactions.map((TransactionModel item) => item.category).toSet(),
    ];
  }

  List<String> get members {
    return [
      'All',
      ...transactions.map((TransactionModel item) => item.member).toSet(),
    ];
  }

  List<String> get accounts {
    return [
      'All',
      ...transactions.map((TransactionModel item) => item.account).toSet(),
    ];
  }

  void changeCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void changeMember(String value) {
    selectedMember = value;
    notifyListeners();
  }

  void changeAccount(String value) {
    selectedAccount = value;
    notifyListeners();
  }

  void changeType(String value) {
    selectedType = value;
    notifyListeners();
  }

  void changeDateRange(DateTimeRange value) {
    selectedDateRange = value;
    notifyListeners();
  }

  void clearDateRange() {
    selectedDateRange = null;
    notifyListeners();
  }

  void clearFilters() {
    selectedCategory = 'All';
    selectedMember = 'All';
    selectedAccount = 'All';
    selectedType = 'All';
    selectedDateRange = null;
    notifyListeners();
  }
}