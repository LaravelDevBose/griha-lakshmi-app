import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/models/purchase_planner_action_response_model.dart';
import '../../data/models/purchase_planner_response_model.dart';
import '../../data/repositories/purchase_planner_repository.dart';

class PurchasePlannerController extends ChangeNotifier {
  PurchasePlannerController({
    required PurchasePlannerRepository repository,
  }) : _repository = repository;

  final PurchasePlannerRepository _repository;

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

  int totalItems = 0;
  int urgentItems = 0;
  int completedItems = 0;
  double estimatedTotal = 0;

  String selectedTab = 'All';

  List<PurchaseItemModel> items = [];

  final List<String> tabs = const [
    'All',
    'Urgent',
    'Assigned to Me',
    'Completed',
  ];

  final List<String> categories = const [
    'Home Appliance',
    'Grocery',
    'Education',
    'Health',
    'Electronics',
    'Furniture',
    'Clothing',
    'Other',
  ];

  final List<String> priorities = const [
    'Urgent',
    'High',
    'Medium',
    'Low',
  ];

  final List<String> members = const [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Self',
  ];

  List<PurchaseItemModel> get filteredItems {
    switch (selectedTab) {
      case 'Urgent':
        return items.where((PurchaseItemModel item) => item.isUrgent).toList();

      case 'Assigned to Me':
        return items
            .where((PurchaseItemModel item) => item.isAssignedToMe)
            .toList();

      case 'Completed':
        return items
            .where((PurchaseItemModel item) => item.isCompleted)
            .toList();

      case 'All':
      default:
        return items;
    }
  }

  void changeTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  Future<void> getItems() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final PurchasePlannerResponseModel response =
          await _repository.getItems(
        page: currentPage,
        perPage: perPage,
      );

      items = response.items;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshItems() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    currentPage = 1;
    hasMorePages = true;
    notifyListeners();

    try {
      final PurchasePlannerResponseModel response =
          await _repository.getItems(
        page: currentPage,
        perPage: perPage,
      );

      items = response.items;
      _applySummary(response);
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh purchase planner. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMoreItems() async {
    if (isLoading || isRefreshing || isLoadingMore || !hasMorePages) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final int nextPage = currentPage + 1;

      final PurchasePlannerResponseModel response =
          await _repository.getItems(
        page: nextPage,
        perPage: perPage,
      );

      currentPage = response.pagination.currentPage;
      items = [
        ...items,
        ...response.items,
      ];
      _applySummary(response);
    } catch (_) {
      // Keep current list visible.
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> storeItem({
    required String productName,
    required double estimatedPrice,
    required String category,
    required String priority,
    required DateTime neededByDate,
    required String assignedTo,
    DateTime? reminderDateTime,
    String? notes,
    String? productImage,
    String? purchaseLink,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.storeItem(
        payload: {
          'product_name': productName,
          'estimated_price': estimatedPrice,
          'final_price': null,
          'category': category,
          'priority': priority,
          'assigned_to': assignedTo,
          'needed_by_date': neededByDate.toIso8601String(),
          'reminder_date_time': reminderDateTime?.toIso8601String(),
          'status': 'assigned',
          'notes': notes,
          'product_image': productImage,
          'purchase_link': purchaseLink,
        },
      );

      if (response.item != null) {
        items = [
          response.item!,
          ...items,
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
      errorMessage = 'Unable to save purchase item. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateItem({
    required int id,
    required String productName,
    required double estimatedPrice,
    required String category,
    required String priority,
    required DateTime neededByDate,
    required String assignedTo,
    DateTime? reminderDateTime,
    String? notes,
    String? productImage,
    String? purchaseLink,
    required String status,
    double? finalPrice,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.updateItem(
        id: id,
        payload: {
          'product_name': productName,
          'estimated_price': estimatedPrice,
          'final_price': finalPrice,
          'category': category,
          'priority': priority,
          'assigned_to': assignedTo,
          'needed_by_date': neededByDate.toIso8601String(),
          'reminder_date_time': reminderDateTime?.toIso8601String(),
          'status': status,
          'notes': notes,
          'product_image': productImage,
          'purchase_link': purchaseLink,
        },
      );

      if (response.item != null) {
        items = items.map((PurchaseItemModel item) {
          if (item.id == id) {
            return response.item!;
          }

          return item;
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
      errorMessage = 'Unable to update purchase item. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> assignItem({
    required int id,
    required String assignedTo,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.assignItem(
        id: id,
        assignedTo: assignedTo,
      );

      items = items.map((PurchaseItemModel item) {
        if (item.id == id) {
          return item.copyWith(
            assignedTo: assignedTo,
            status: 'assigned',
          );
        }

        return item;
      }).toList();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to assign item. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> markPurchased({
    required int id,
    required double finalPrice,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.markPurchased(
        id: id,
        finalPrice: finalPrice,
      );

      items = items.map((PurchaseItemModel item) {
        if (item.id == id) {
          return item.copyWith(
            finalPrice: finalPrice,
            status: 'completed',
          );
        }

        return item;
      }).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to mark item as purchased. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> cancelItem(int id) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.cancelItem(id: id);

      items = items.map((PurchaseItemModel item) {
        if (item.id == id) {
          return item.copyWith(status: 'cancelled');
        }

        return item;
      }).toList();

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to cancel item. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteItem(int id) async {
    isDeleting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final PurchasePlannerActionResponseModel response =
          await _repository.deleteItem(id: id);

      items = items.where((PurchaseItemModel item) => item.id != id).toList();

      _recalculateLocalSummary();

      successMessage = response.message;
      isDeleting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to delete item. Please try again.';
    }

    isDeleting = false;
    notifyListeners();
    return false;
  }

  void _applySummary(PurchasePlannerResponseModel response) {
    totalItems = response.summary.totalItems;
    urgentItems = response.summary.urgentItems;
    completedItems = response.summary.completedItems;
    estimatedTotal = response.summary.estimatedTotal;
    hasMorePages = response.pagination.hasMorePages;
    currentPage = response.pagination.currentPage;
  }

  void _recalculateLocalSummary() {
    totalItems = items.length;
    urgentItems = items.where((PurchaseItemModel item) => item.isUrgent).length;
    completedItems =
        items.where((PurchaseItemModel item) => item.isCompleted).length;

    estimatedTotal = items.fold(
      0,
      (double sum, PurchaseItemModel item) => sum + item.estimatedPrice,
    );
  }
}