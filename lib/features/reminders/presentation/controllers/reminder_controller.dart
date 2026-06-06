import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/reminder_action_response_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/reminder_response_model.dart';
import '../../data/repositories/reminder_repository.dart';

class ReminderController extends ChangeNotifier {
  ReminderController({
    required ReminderRepository repository,
  }) : _repository = repository;

  final ReminderRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  int currentPage = 1;
  int perPage = 10;
  bool hasMorePages = true;

  int totalReminders = 0;
  int todayReminders = 0;
  int upcomingReminders = 0;
  int completedReminders = 0;
  int snoozedReminders = 0;

  String selectedTab = 'Today';

  List<ReminderModel> reminders = [];

  final List<String> tabs = const [
    'Today',
    'Upcoming',
    'Completed',
    'Snoozed',
  ];

  final List<String> relatedTypes = const [
    'custom',
    'bill',
    'loan',
    'credit_card',
    'savings_goal',
    'budget',
    'purchase_planner',
  ];

  final List<String> members = const [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Self',
  ];

  final List<int> snoozeOptions = const [
    15,
    30,
    60,
    1440,
  ];

  List<ReminderModel> get filteredReminders {
    switch (selectedTab) {
      case 'Today':
        return reminders
            .where((ReminderModel reminder) => reminder.isToday)
            .toList();

      case 'Upcoming':
        return reminders
            .where((ReminderModel reminder) => reminder.isUpcoming)
            .toList();

      case 'Completed':
        return reminders
            .where((ReminderModel reminder) => reminder.isCompleted)
            .toList();

      case 'Snoozed':
        return reminders
            .where((ReminderModel reminder) => reminder.isSnoozed)
            .toList();

      default:
        return reminders;
    }
  }

  void changeTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  String statusFromDate(DateTime dateTime) {
    final DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'today';
    }

    return 'upcoming';
  }

  Future<void> getReminders() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final ReminderResponseModel response = await _repository.getReminders(
        page: currentPage,
        perPage: perPage,
      );

      reminders = response.reminders;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshReminders() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final ReminderResponseModel response = await _repository.getReminders(
        page: currentPage,
        perPage: perPage,
      );

      reminders = response.reminders;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh reminders. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreReminders() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final ReminderResponseModel response = await _repository.getReminders(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;

      reminders = [
        ...reminders,
        ...response.reminders,
      ];

      _applySummary(response);
    } catch (_) {
      // Keep existing list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeReminder({
    required String title,
    required String message,
    required String relatedType,
    required int relatedId,
    required String relatedTitle,
    required DateTime dateTime,
    required String assignedUser,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final String status = statusFromDate(dateTime);

      final ReminderActionResponseModel response =
          await _repository.storeReminder(
        payload: {
          'title': title,
          'message': message,
          'related_type': relatedType,
          'related_id': relatedId,
          'related_title': relatedTitle,
          'date_time': dateTime.toIso8601String(),
          'assigned_user': assignedUser,
          'status': status,
        },
      );

      if (response.reminder != null) {
        reminders = [
          response.reminder!,
          ...reminders,
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
      errorMessage = 'Unable to save reminder. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateReminder({
    required int id,
    required String title,
    required String message,
    required String relatedType,
    required int relatedId,
    required String relatedTitle,
    required DateTime dateTime,
    required String assignedUser,
    required String currentStatus,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      String status = currentStatus;

      if (currentStatus != 'completed' && currentStatus != 'snoozed') {
        status = statusFromDate(dateTime);
      }

      final ReminderActionResponseModel response =
          await _repository.updateReminder(
        id: id,
        payload: {
          'title': title,
          'message': message,
          'related_type': relatedType,
          'related_id': relatedId,
          'related_title': relatedTitle,
          'date_time': dateTime.toIso8601String(),
          'assigned_user': assignedUser,
          'status': status,
        },
      );

      if (response.reminder != null) {
        reminders = reminders.map((ReminderModel reminder) {
          if (reminder.id == id) {
            return response.reminder!;
          }

          return reminder;
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
      errorMessage = 'Unable to update reminder. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> completeReminder(int id) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ReminderActionResponseModel response =
          await _repository.completeReminder(id: id);

      reminders = reminders.map((ReminderModel reminder) {
        if (reminder.id == id) {
          return reminder.copyWith(status: 'completed');
        }

        return reminder;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to complete reminder. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> snoozeReminder({
    required int id,
    required int snoozeMinutes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ReminderActionResponseModel response =
          await _repository.snoozeReminder(
        id: id,
        snoozeMinutes: snoozeMinutes,
      );

      reminders = reminders.map((ReminderModel reminder) {
        if (reminder.id == id) {
          return reminder.copyWith(status: 'snoozed');
        }

        return reminder;
      }).toList();

      _recalculateLocalSummary();

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

  void _applySummary(ReminderResponseModel response) {
    totalReminders = response.summary.totalReminders;
    todayReminders = response.summary.todayReminders;
    upcomingReminders = response.summary.upcomingReminders;
    completedReminders = response.summary.completedReminders;
    snoozedReminders = response.summary.snoozedReminders;
    currentPage = response.pagination.currentPage;
    hasMorePages = response.pagination.hasMorePages;
  }

  void _recalculateLocalSummary() {
    totalReminders = reminders.length;

    todayReminders =
        reminders.where((ReminderModel reminder) => reminder.isToday).length;

    upcomingReminders = reminders
        .where((ReminderModel reminder) => reminder.isUpcoming)
        .length;

    completedReminders = reminders
        .where((ReminderModel reminder) => reminder.isCompleted)
        .length;

    snoozedReminders = reminders
        .where((ReminderModel reminder) => reminder.isSnoozed)
        .length;
  }
}