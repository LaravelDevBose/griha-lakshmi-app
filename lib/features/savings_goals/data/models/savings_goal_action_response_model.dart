import 'savings_goal_model.dart';

class SavingsGoalActionResponseModel {
  const SavingsGoalActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.savingsGoal,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final SavingsGoalModel? savingsGoal;

  factory SavingsGoalActionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic goalJson = data['savings_goal'];

    return SavingsGoalActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      savingsGoal: goalJson is Map<String, dynamic>
          ? SavingsGoalModel.fromJson(goalJson)
          : null,
    );
  }
}