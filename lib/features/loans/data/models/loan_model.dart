class LoanModel {
  const LoanModel({
    required this.id,
    required this.loanName,
    required this.lenderName,
    required this.originalAmount,
    required this.remainingBalance,
    required this.installmentAmount,
    required this.startDate,
    required this.dueDay,
    required this.expectedEndDate,
    required this.assignedPerson,
    required this.reminderDaysBefore,
    required this.reminderTime,
    required this.status,
    this.interestRate,
  });

  final int id;
  final String loanName;
  final String lenderName;
  final double originalAmount;
  final double remainingBalance;
  final double installmentAmount;
  final double? interestRate;
  final DateTime startDate;
  final int dueDay;
  final DateTime expectedEndDate;
  final String assignedPerson;
  final int reminderDaysBefore;
  final String reminderTime;
  final String status;

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isActive => status.toLowerCase() == 'active';

  bool get canRecordPayment => remainingBalance > 0 && !isCompleted;

  double get paidAmount {
    final double paid = originalAmount - remainingBalance;
    return paid < 0 ? 0 : paid;
  }

  double get progressPercentage {
    if (originalAmount <= 0) return 0;

    final double progress = (paidAmount / originalAmount) * 100;

    if (progress < 0) return 0;
    if (progress > 100) return 100;

    return progress;
  }

  DateTime get nextDueDate {
    final DateTime now = DateTime.now();
    final int safeDay = dueDay.clamp(1, 28);

    DateTime dueDate = DateTime(now.year, now.month, safeDay);

    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      dueDate = DateTime(now.year, now.month + 1, safeDay);
    }

    return dueDate;
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      loanName: json['loan_name']?.toString() ?? '',
      lenderName: json['lender_name']?.toString() ?? '',
      originalAmount:
          double.tryParse(json['original_amount'].toString()) ?? 0,
      remainingBalance:
          double.tryParse(json['remaining_balance'].toString()) ?? 0,
      installmentAmount:
          double.tryParse(json['installment_amount'].toString()) ?? 0,
      interestRate: json['interest_rate'] == null
          ? null
          : double.tryParse(json['interest_rate'].toString()),
      startDate:
          DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now(),
      dueDay: int.tryParse(json['due_day'].toString()) ?? 1,
      expectedEndDate:
          DateTime.tryParse(json['expected_end_date'].toString()) ??
              DateTime.now(),
      assignedPerson: json['assigned_person']?.toString() ?? '',
      reminderDaysBefore:
          int.tryParse(json['reminder_days_before'].toString()) ?? 1,
      reminderTime: json['reminder_time']?.toString() ?? '09:00',
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toPayload() {
    return {
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
      'status': status,
    };
  }

  LoanModel copyWith({
    int? id,
    String? loanName,
    String? lenderName,
    double? originalAmount,
    double? remainingBalance,
    double? installmentAmount,
    double? interestRate,
    DateTime? startDate,
    int? dueDay,
    DateTime? expectedEndDate,
    String? assignedPerson,
    int? reminderDaysBefore,
    String? reminderTime,
    String? status,
  }) {
    return LoanModel(
      id: id ?? this.id,
      loanName: loanName ?? this.loanName,
      lenderName: lenderName ?? this.lenderName,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      dueDay: dueDay ?? this.dueDay,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
    );
  }
}