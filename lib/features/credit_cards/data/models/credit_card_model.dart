class CreditCardModel {
  const CreditCardModel({
    required this.id,
    required this.cardName,
    required this.bankName,
    required this.lastFourDigits,
    required this.creditLimit,
    required this.outstandingBalance,
    required this.statementDay,
    required this.dueDay,
    required this.minimumPayment,
    required this.assignedPerson,
    required this.reminderDaysBefore,
    required this.reminderTime,
    required this.status,
  });

  final int id;
  final String cardName;
  final String bankName;
  final String lastFourDigits;
  final double creditLimit;
  final double outstandingBalance;
  final int statementDay;
  final int dueDay;
  final double minimumPayment;
  final String assignedPerson;
  final int reminderDaysBefore;
  final String reminderTime;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';

  bool get isPaid => outstandingBalance <= 0;

  bool get canRecordPayment => outstandingBalance > 0;

  double get usedPercentage {
    if (creditLimit <= 0) return 0;

    final double percentage = (outstandingBalance / creditLimit) * 100;

    if (percentage < 0) return 0;
    if (percentage > 100) return 100;

    return percentage;
  }

  double get availableLimit {
    final double available = creditLimit - outstandingBalance;
    return available < 0 ? 0 : available;
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

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      cardName: json['card_name']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      lastFourDigits: json['last_four_digits']?.toString() ?? '',
      creditLimit: double.tryParse(json['credit_limit'].toString()) ?? 0,
      outstandingBalance:
          double.tryParse(json['outstanding_balance'].toString()) ?? 0,
      statementDay: int.tryParse(json['statement_day'].toString()) ?? 1,
      dueDay: int.tryParse(json['due_day'].toString()) ?? 1,
      minimumPayment:
          double.tryParse(json['minimum_payment'].toString()) ?? 0,
      assignedPerson: json['assigned_person']?.toString() ?? '',
      reminderDaysBefore:
          int.tryParse(json['reminder_days_before'].toString()) ?? 1,
      reminderTime: json['reminder_time']?.toString() ?? '09:00',
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toPayload() {
    return {
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
    };
  }

  CreditCardModel copyWith({
    int? id,
    String? cardName,
    String? bankName,
    String? lastFourDigits,
    double? creditLimit,
    double? outstandingBalance,
    int? statementDay,
    int? dueDay,
    double? minimumPayment,
    String? assignedPerson,
    int? reminderDaysBefore,
    String? reminderTime,
    String? status,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      bankName: bankName ?? this.bankName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
    );
  }
}