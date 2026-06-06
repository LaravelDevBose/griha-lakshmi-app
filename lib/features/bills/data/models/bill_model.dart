class BillModel {
  const BillModel({
    required this.id,
    required this.billName,
    required this.billType,
    required this.expectedAmount,
    required this.dueDate,
    required this.repeatFrequency,
    required this.assignedPerson,
    required this.reminderDaysBefore,
    required this.reminderTime,
    required this.status,
    required this.hasReminder,
    this.paidAmount,
    this.paymentAccount,
    this.notes,
  });

  final int id;
  final String billName;
  final String billType;
  final double expectedAmount;
  final double? paidAmount;
  final String? paymentAccount;
  final DateTime dueDate;
  final String repeatFrequency;
  final String assignedPerson;
  final int reminderDaysBefore;
  final String reminderTime;
  final String status;
  final bool hasReminder;
  final String? notes;

  bool get isUpcoming => status.toLowerCase() == 'upcoming';

  bool get isPaid => status.toLowerCase() == 'paid';

  bool get isOverdue => status.toLowerCase() == 'overdue';

  bool get canMarkPaid => !isPaid;

  bool get canSnooze => !isPaid && hasReminder;

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      billName: json['bill_name']?.toString() ?? '',
      billType: json['bill_type']?.toString() ?? '',
      expectedAmount:
          double.tryParse(json['expected_amount'].toString()) ?? 0,
      paidAmount: json['paid_amount'] == null
          ? null
          : double.tryParse(json['paid_amount'].toString()),
      paymentAccount: json['payment_account']?.toString(),
      dueDate: DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now(),
      repeatFrequency: json['repeat_frequency']?.toString() ?? 'Monthly',
      assignedPerson: json['assigned_person']?.toString() ?? '',
      reminderDaysBefore:
          int.tryParse(json['reminder_days_before'].toString()) ?? 1,
      reminderTime: json['reminder_time']?.toString() ?? '09:00',
      status: json['status']?.toString() ?? 'upcoming',
      hasReminder: json['has_reminder'] == true ||
          json['has_reminder'] == 1 ||
          json['has_reminder']?.toString() == '1',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
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
    };
  }

  BillModel copyWith({
    int? id,
    String? billName,
    String? billType,
    double? expectedAmount,
    double? paidAmount,
    String? paymentAccount,
    DateTime? dueDate,
    String? repeatFrequency,
    String? assignedPerson,
    int? reminderDaysBefore,
    String? reminderTime,
    String? status,
    bool? hasReminder,
    String? notes,
  }) {
    return BillModel(
      id: id ?? this.id,
      billName: billName ?? this.billName,
      billType: billType ?? this.billType,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      dueDate: dueDate ?? this.dueDate,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      hasReminder: hasReminder ?? this.hasReminder,
      notes: notes ?? this.notes,
    );
  }
}