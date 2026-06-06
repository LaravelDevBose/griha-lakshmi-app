import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/credit_card_action_response_model.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/models/credit_card_response_model.dart';
import '../../data/repositories/credit_card_repository.dart';

class CreditCardController extends ChangeNotifier {
  CreditCardController({
    required CreditCardRepository repository,
  }) : _repository = repository;

  final CreditCardRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalCards = 0;
  double totalLimit = 0;
  double totalOutstandingBalance = 0;
  double minimumPaymentTotal = 0;

  List<CreditCardModel> creditCards = [];

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

  Future<void> getCreditCards() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final CreditCardResponseModel response =
          await _repository.getCreditCards(
        page: currentPage,
        perPage: perPage,
      );

      creditCards = response.creditCards;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCreditCards() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final CreditCardResponseModel response =
          await _repository.getCreditCards(
        page: currentPage,
        perPage: perPage,
      );

      creditCards = response.creditCards;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh credit card list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreCreditCards() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final CreditCardResponseModel response =
          await _repository.getCreditCards(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      creditCards = [
        ...creditCards,
        ...response.creditCards,
      ];
      _applySummary(response);
    } catch (_) {
      // Keep current list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeCreditCard({
    required String cardName,
    required String bankName,
    required String lastFourDigits,
    required double creditLimit,
    required double outstandingBalance,
    required int statementDay,
    required int dueDay,
    required double minimumPayment,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final CreditCardActionResponseModel response =
          await _repository.storeCreditCard(
        payload: {
          'card_name': cardName,
          'bank_name': bankName,
          'last_four_digits': lastFourDigits,
          'credit_limit': creditLimit,
          'outstanding_balance': outstandingBalance,
          'statement_day': statementDay,
          'due_day': dueDay,
          'minimum_payment': minimumPayment,
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': 'active',
        },
      );

      if (response.creditCard != null) {
        creditCards = [
          response.creditCard!,
          ...creditCards,
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
      errorMessage = 'Unable to save credit card. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateCreditCard({
    required int id,
    required String cardName,
    required String bankName,
    required String lastFourDigits,
    required double creditLimit,
    required double outstandingBalance,
    required int statementDay,
    required int dueDay,
    required double minimumPayment,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
    required String status,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final CreditCardActionResponseModel response =
          await _repository.updateCreditCard(
        id: id,
        payload: {
          'card_name': cardName,
          'bank_name': bankName,
          'last_four_digits': lastFourDigits,
          'credit_limit': creditLimit,
          'outstanding_balance': outstandingBalance,
          'statement_day': statementDay,
          'due_day': dueDay,
          'minimum_payment': minimumPayment,
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': status,
        },
      );

      if (response.creditCard != null) {
        creditCards = creditCards.map((CreditCardModel card) {
          if (card.id == id) {
            return response.creditCard!;
          }

          return card;
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
      errorMessage = 'Unable to update credit card. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> recordPayment({
    required int id,
    required double paymentAmount,
    required String paymentAccount,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final CreditCardActionResponseModel response =
          await _repository.recordPayment(
        id: id,
        paymentAmount: paymentAmount,
        paymentAccount: paymentAccount,
      );

      creditCards = creditCards.map((CreditCardModel card) {
        if (card.id == id) {
          final double updatedBalance = card.outstandingBalance - paymentAmount;
          final double safeBalance = updatedBalance < 0 ? 0 : updatedBalance;

          return card.copyWith(
            outstandingBalance: safeBalance,
          );
        }

        return card;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to record credit card payment. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  void _applySummary(CreditCardResponseModel response) {
    totalCards = response.summary.totalCards;
    totalLimit = response.summary.totalLimit;
    totalOutstandingBalance = response.summary.totalOutstandingBalance;
    minimumPaymentTotal = response.summary.minimumPaymentTotal;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalCards = creditCards.length;

    totalLimit = creditCards.fold(
      0,
      (double sum, CreditCardModel card) => sum + card.creditLimit,
    );

    totalOutstandingBalance = creditCards.fold(
      0,
      (double sum, CreditCardModel card) => sum + card.outstandingBalance,
    );

    minimumPaymentTotal = creditCards.fold(
      0,
      (double sum, CreditCardModel card) => sum + card.minimumPayment,
    );
  }
}