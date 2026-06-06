import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/bill_action_response_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/bill_response_model.dart';
import '../../data/repositories/bill_repository.dart';

class BillController extends ChangeNotifier {
  BillController({
    required BillRepository repository,
  }) : _repository = repository;

  final BillRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalBills = 0;
  int upcomingBills = 0;
  int paidBills = 0;
  int overdueBills = 0;
  double expectedTotal = 0;

  String selectedTab = 'Upcoming';

  List<BillModel> bills = [];

  final List<String> tabs = const [
    'Upcoming',
    'Paid',
    'Overdue',
    'All',
  ];

  final List<String> billTypes = const [
    'Utility',
    'Rent',
    'Credit Card',
    'Subscription',
    'Education',
    'Health',
    'Other',
  ];

  final List<String> repeatFrequencies = const [
    'One Time',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
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

  List<BillModel> get filteredBills {
    switch (selectedTab) {
      case 'Upcoming':
        return bills.where((BillModel bill) => bill.isUpcoming).toList();

      case 'Paid':
        return bills.where((BillModel bill) => bill.isPaid).toList();

      case 'Overdue':
        return bills.where((BillModel bill) => bill.isOverdue).toList();

      case 'All':
      default:
        return bills;
    }
  }

  void changeTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  Future<void> getBills() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final BillResponseModel response = await _repository.getBills(
        page: currentPage,
        perPage: perPage,
      );

      bills = response.bills;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshBills() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final BillResponseModel response = await _repository.getBills(
        page: currentPage,
        perPage: perPage,
      );

      bills = response.bills;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh bill list. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreBills() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final BillResponseModel response = await _repository.getBills(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      bills = [
        ...bills,
        ...response.bills,
      ];
      _applySummary(response);
    } catch (_) {
      // Keep existing list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeBill({
    required String billName,
    required String billType,
    required double expectedAmount,
    required DateTime dueDate,
    required String repeatFrequency,
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
      final BillActionResponseModel response = await _repository.storeBill(
        payload: {
          'bill_name': billName,
          'bill_type': billType,
          'expected_amount': expectedAmount,
          'paid_amount': null,
          'payment_account': null,
          'due_date': dueDate.toIso8601String(),
          'repeat_frequency': repeatFrequency,
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': 'upcoming',
          'has_reminder': true,
          'notes': notes,
        },
      );

      if (response.bill != null) {
        bills = [
          response.bill!,
          ...bills,
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
      errorMessage = 'Unable to save bill. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBill({
    required int id,
    required String billName,
    required String billType,
    required double expectedAmount,
    required DateTime dueDate,
    required String repeatFrequency,
    required String assignedPerson,
    required int reminderDaysBefore,
    required String reminderTime,
    required String status,
    required bool hasReminder,
    double? paidAmount,
    String? paymentAccount,
    String? notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final BillActionResponseModel response = await _repository.updateBill(
        id: id,
        payload: {
          'bill_name': billName,
          'bill_type': billType,
          'expected_amount': expectedAmount,
          'paid_amount': paidAmount,
          'payment_account': paymentAccount,
          'due_date': dueDate.toIso8601String(),
          'repeat_frequency': repeatFrequency,
          'assigned_person': assignedPerson,
          'reminder_days_before': reminderDaysBefore,
          'reminder_time': reminderTime,
          'status': status,
          'has_reminder': hasReminder,
          'notes': notes,
        },
      );

      if (response.bill != null) {
        bills = bills.map((BillModel bill) {
          if (bill.id == id) {
            return response.bill!;
          }

          return bill;
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
      errorMessage = 'Unable to update bill. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> markBillPaid({
    required int id,
    required double paidAmount,
    required String paymentAccount,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final BillActionResponseModel response = await _repository.markBillPaid(
        id: id,
        paidAmount: paidAmount,
        paymentAccount: paymentAccount,
      );

      bills = bills.map((BillModel bill) {
        if (bill.id == id) {
          return bill.copyWith(
            status: 'paid',
            hasReminder: false,
            paidAmount: paidAmount,
            paymentAccount: paymentAccount,
          );
        }

        return bill;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to mark bill as paid. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> snoozeBill(int id) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final BillActionResponseModel response =
          await _repository.snoozeBill(id: id);

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to snooze reminder. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  void _applySummary(BillResponseModel response) {
    totalBills = response.summary.totalBills;
    upcomingBills = response.summary.upcomingBills;
    paidBills = response.summary.paidBills;
    overdueBills = response.summary.overdueBills;
    expectedTotal = response.summary.expectedTotal;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalBills = bills.length;
    upcomingBills = bills.where((BillModel bill) => bill.isUpcoming).length;
    paidBills = bills.where((BillModel bill) => bill.isPaid).length;
    overdueBills = bills.where((BillModel bill) => bill.isOverdue).length;

    expectedTotal = bills.fold(
      0,
      (double sum, BillModel bill) => sum + bill.expectedAmount,
    );
  }
}