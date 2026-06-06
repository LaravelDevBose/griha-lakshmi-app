class SavingsGoalModel {
  const SavingsGoalModel({
    required this.id,
    required this.goalName,
    required this.goalType,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyDepositTarget,
    required this.depositDueDay,
    required this.targetDate,
    required this.assignedPerson,
    required this.reminderDaysBefore,
    required this.reminderTime,
    required this.status,
    this.notes,
  });

  final int id;
  final String goalName;
  final String goalType;
  final double targetAmount;
  final double currentAmount;
  final double monthlyDepositTarget;
  final int depositDueDay;
  final DateTime targetDate;
  final String assignedPerson;
  final int reminderDaysBefore;
  final String reminderTime;
  final String status;
  final String? notes;

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isActive => status.toLowerCase() == 'active';

  bool get canRecordDeposit => !isCompleted && currentAmount < targetAmount;

  double get remainingAmount {
    final double remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0;

    final double progress = (currentAmount / targetAmount) * 100;

    if (progress < 0) return 0;
    if (progress > 100) return 100;

    return progress;
  }

  DateTime get nextDepositDate {
    final DateTime now = DateTime.now();
    final int safeDay = depositDueDay.clamp(1, 28);

    DateTime depositDate = DateTime(now.year, now.month, safeDay);

    if (depositDate.isBefore(DateTime(now.year, now.month, now.day))) {
      depositDate = DateTime(now.year, now.month + 1, safeDay);
    }

    return depositDate;
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      goalName: json['goal_name']?.toString() ?? '',
      goalType: json['goal_type']?.toString() ?? '',
      targetAmount: double.tryParse(json['target_amount'].toString()) ?? 0,
      currentAmount: double.tryParse(json['current_amount'].toString()) ?? 0,
      monthlyDepositTarget:
          double.tryParse(json['monthly_deposit_target'].toString()) ?? 0,
      depositDueDay: int.tryParse(json['deposit_due_day'].toString()) ?? 1,
      targetDate:
          DateTime.tryParse(json['target_date'].toString()) ?? DateTime.now(),
      assignedPerson: json['assigned_person']?.toString() ?? '',
      reminderDaysBefore:
          int.tryParse(json['reminder_days_before'].toString()) ?? 1,
      reminderTime: json['reminder_time']?.toString() ?? '09:00',
      status: json['status']?.toString() ?? 'active',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'goal_name': goalName,
      'goal_type': goalType,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'monthly_deposit_target': monthlyDepositTarget,
      'deposit_due_day': depositDueDay,
      'target_date': targetDate.toIso8601String(),
      'assigned_person': assignedPerson,
      'reminder_days_before': reminderDaysBefore,
      'reminder_time': reminderTime,
      'status': status,
      'notes': notes,
    };
  }

  SavingsGoalModel copyWith({
    int? id,
    String? goalName,
    String? goalType,
    double? targetAmount,
    double? currentAmount,
    double? monthlyDepositTarget,
    int? depositDueDay,
    DateTime? targetDate,
    String? assignedPerson,
    int? reminderDaysBefore,
    String? reminderTime,
    String? status,
    String? notes,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      goalName: goalName ?? this.goalName,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyDepositTarget:
          monthlyDepositTarget ?? this.monthlyDepositTarget,
      depositDueDay: depositDueDay ?? this.depositDueDay,
      targetDate: targetDate ?? this.targetDate,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}