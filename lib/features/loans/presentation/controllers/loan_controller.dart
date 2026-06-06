import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/loan_action_response_model.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/loan_response_model.dart';
import '../../data/repositories/loan_repository.dart';

class LoanController extends ChangeNotifier {
  LoanController({
    required LoanRepository repository,
  }) : _repository = repository;

  final LoanRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalLoans = 0;
  int activeLoans = 0;
  int completedLoans = 0;
  double totalRemainingBalance = 0;
  double monthlyInstallmentTotal = 0;

  List<LoanModel> loans = [];

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

  Future<void> getLoans() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final LoanResponseModel response = await _repository.getLoans(
        page: currentPage,
        perPage: perPage,
      );

      loans = response.loans;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshLoans() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final LoanResponseModel response = await _repository.getLoans(
        page: currentPage,
        perPage: perPage,
      );

      loans = response.loans;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh loan list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreLoans() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final LoanResponseModel response = await _repository.getLoans(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      loans = [
        ...loans,
        ...response.loans,
      ];
      _applySummary(response);
    } catch (_) {
      // Keep current list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeLoan({
    required String loanName,
    required String lenderName,
    required double originalAmount,
    required double remainingBalance,
    required double installmentAmount,
    double? interestRate,
    required DateTime startDate,
    required int dueDay,
    required DateTime expectedEndDate,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final LoanActionResponseModel response = await _repository.storeLoan(
        payload: {
          'loan_name': loanName,
          'lender_name': lenderName,
          'original_amount': originalAmount,
          'remaining_balance': remainingBalance,
          'installment_amount': installmentAmount,
          'interest_rate': interestRate,
          'start_date': startDate.toIso8601String(),
          'due_day': dueDay,
          'expected_end_date': expectedEndDate.toIso8601String(),
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': remainingBalance <= 0 ? 'completed' : 'active',
        },
      );

      if (response.loan != null) {
        loans = [
          response.loan!,
          ...loans,
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
      errorMessage = 'Unable to save loan. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateLoan({
    required int id,
    required String loanName,
    required String lenderName,
    required double originalAmount,
    required double remainingBalance,
    required double installmentAmount,
    double? interestRate,
    required DateTime startDate,
    required int dueDay,
    required DateTime expectedEndDate,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final LoanActionResponseModel response = await _repository.updateLoan(
        id: id,
        payload: {
          'loan_name': loanName,
          'lender_name': lenderName,
          'original_amount': originalAmount,
          'remaining_balance': remainingBalance,
          'installment_amount': installmentAmount,
          'interest_rate': interestRate,
          'start_date': startDate.toIso8601String(),
          'due_day': dueDay,
          'expected_end_date': expectedEndDate.toIso8601String(),
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': remainingBalance <= 0 ? 'completed' : 'active',
        },
      );

      if (response.loan != null) {
        loans = loans.map((LoanModel loan) {
          if (loan.id == id) {
            return response.loan!;
          }

          return loan;
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
      errorMessage = 'Unable to update loan. Please try again.';
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
      final LoanActionResponseModel response = await _repository.recordPayment(
        id: id,
        paymentAmount: paymentAmount,
        paymentAccount: paymentAccount,
      );

      loans = loans.map((LoanModel loan) {
        if (loan.id == id) {
          final double updatedBalance = loan.remainingBalance - paymentAmount;
          final double safeBalance = updatedBalance < 0 ? 0 : updatedBalance;

          return loan.copyWith(
            remainingBalance: safeBalance,
            status: safeBalance <= 0 ? 'completed' : 'active',
          );
        }

        return loan;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to record loan payment. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  void _applySummary(LoanResponseModel response) {
    totalLoans = response.summary.totalLoans;
    activeLoans = response.summary.activeLoans;
    completedLoans = response.summary.completedLoans;
    totalRemainingBalance = response.summary.totalRemainingBalance;
    monthlyInstallmentTotal = response.summary.monthlyInstallmentTotal;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalLoans = loans.length;
    activeLoans = loans.where((LoanModel loan) => loan.isActive).length;
    completedLoans = loans.where((LoanModel loan) => loan.isCompleted).length;

    totalRemainingBalance = loans.fold(
      0,
      (double sum, LoanModel loan) => sum + loan.remainingBalance,
    );

    monthlyInstallmentTotal = loans
        .where((LoanModel loan) => loan.isActive)
        .fold(
          0,
          (double sum, LoanModel loan) => sum + loan.installmentAmount,
        );
  }
}