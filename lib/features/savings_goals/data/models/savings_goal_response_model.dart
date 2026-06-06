import 'savings_goal_model.dart';

class SavingsGoalSummaryModel {
  const SavingsGoalSummaryModel({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.targetTotal,
    required this.currentTotal,
    required this.monthlyTargetTotal,
  });

  final int totalGoals;
  final int activeGoals;
  final int completedGoals;
  final double targetTotal;
  final double currentTotal;
  final double monthlyTargetTotal;

  factory SavingsGoalSummaryModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalSummaryModel(
      totalGoals: int.tryParse(json['total_goals'].toString()) ?? 0,
      activeGoals: int.tryParse(json['active_goals'].toString()) ?? 0,
      completedGoals: int.tryParse(json['completed_goals'].toString()) ?? 0,
      targetTotal: double.tryParse(json['target_total'].toString()) ?? 0,
      currentTotal: double.tryParse(json['current_total'].toString()) ?? 0,
      monthlyTargetTotal:
          double.tryParse(json['monthly_target_total'].toString()) ?? 0,
    );
  }
}

class SavingsGoalPaginationModel {
  const SavingsGoalPaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  bool get hasMorePages => currentPage < lastPage;

  factory SavingsGoalPaginationModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class SavingsGoalResponseModel {
  const SavingsGoalResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.savingsGoals,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final SavingsGoalSummaryModel summary;
  final SavingsGoalPaginationModel pagination;
  final List<SavingsGoalModel> savingsGoals;

  factory SavingsGoalResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> goalList = data['savings_goals'] ?? [];

    return SavingsGoalResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: SavingsGoalSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: SavingsGoalPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      savingsGoals: goalList.map((dynamic item) {
        return SavingsGoalModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}