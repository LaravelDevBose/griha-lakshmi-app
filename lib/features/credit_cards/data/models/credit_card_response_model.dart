import 'credit_card_model.dart';

class CreditCardSummaryModel {
  const CreditCardSummaryModel({
    required this.totalCards,
    required this.totalLimit,
    required this.totalOutstandingBalance,
    required this.minimumPaymentTotal,
  });

  final int totalCards;
  final double totalLimit;
  final double totalOutstandingBalance;
  final double minimumPaymentTotal;

  factory CreditCardSummaryModel.fromJson(Map<String, dynamic> json) {
    return CreditCardSummaryModel(
      totalCards: int.tryParse(json['total_cards'].toString()) ?? 0,
      totalLimit: double.tryParse(json['total_limit'].toString()) ?? 0,
      totalOutstandingBalance:
          double.tryParse(json['total_outstanding_balance'].toString()) ?? 0,
      minimumPaymentTotal:
          double.tryParse(json['minimum_payment_total'].toString()) ?? 0,
    );
  }
}

class CreditCardPaginationModel {
  const CreditCardPaginationModel({
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

  factory CreditCardPaginationModel.fromJson(Map<String, dynamic> json) {
    return CreditCardPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class CreditCardResponseModel {
  const CreditCardResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.creditCards,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final CreditCardSummaryModel summary;
  final CreditCardPaginationModel pagination;
  final List<CreditCardModel> creditCards;

  factory CreditCardResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> cardList = data['credit_cards'] ?? [];

    return CreditCardResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: CreditCardSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: CreditCardPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      creditCards: cardList.map((dynamic item) {
        return CreditCardModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}