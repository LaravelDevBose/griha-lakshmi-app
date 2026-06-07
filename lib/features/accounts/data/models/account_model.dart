class AccountModel {
  const AccountModel({
    required this.id,
    required this.accountName,
    required this.accountType,
    required this.institutionName,
    required this.accountNumberLastFour,
    required this.openingBalance,
    required this.currentBalance,
    required this.currency,
    required this.isDefault,
    required this.status,
    this.notes,
  });

  final int id;
  final String accountName;
  final String accountType;
  final String institutionName;
  final String accountNumberLastFour;
  final double openingBalance;
  final double currentBalance;
  final String currency;
  final bool isDefault;
  final String status;
  final String? notes;

  bool get isActive => status.toLowerCase() == 'active';

  String get accountTypeLabel {
    switch (accountType) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank';
      case 'mobile_banking':
        return 'Mobile Banking';
      case 'card':
        return 'Card';
      case 'wallet':
        return 'Wallet';
      default:
        return accountType;
    }
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      accountName: json['account_name']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? 'cash',
      institutionName: json['institution_name']?.toString() ?? '',
      accountNumberLastFour:
          json['account_number_last_four']?.toString() ?? '',
      openingBalance:
          double.tryParse(json['opening_balance'].toString()) ?? 0,
      currentBalance:
          double.tryParse(json['current_balance'].toString()) ?? 0,
      currency: json['currency']?.toString() ?? 'BDT',
      isDefault: json['is_default'] == true ||
          json['is_default']?.toString() == '1' ||
          json['is_default']?.toString() == 'true',
      status: json['status']?.toString() ?? 'active',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'account_name': accountName,
      'account_type': accountType,
      'institution_name': institutionName,
      'account_number_last_four': accountNumberLastFour,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'currency': currency,
      'is_default': isDefault,
      'status': status,
      'notes': notes,
    };
  }

  AccountModel copyWith({
    int? id,
    String? accountName,
    String? accountType,
    String? institutionName,
    String? accountNumberLastFour,
    double? openingBalance,
    double? currentBalance,
    String? currency,
    bool? isDefault,
    String? status,
    String? notes,
  }) {
    return AccountModel(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      institutionName: institutionName ?? this.institutionName,
      accountNumberLastFour:
          accountNumberLastFour ?? this.accountNumberLastFour,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}