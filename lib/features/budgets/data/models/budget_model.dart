class BudgetCategoryModel {
  const BudgetCategoryModel({
    required this.id,
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
  });

  final int id;
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;

  double get remainingAmount {
    final double remaining = budgetAmount - spentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  double get overBudgetAmount {
    final double over = spentAmount - budgetAmount;
    return over < 0 ? 0 : over;
  }

  bool get isOverBudget => spentAmount > budgetAmount;

  double get usedPercentage {
    if (budgetAmount <= 0) return 0;

    final double percentage = (spentAmount / budgetAmount) * 100;

    if (percentage < 0) return 0;
    if (percentage > 100) return 100;

    return percentage;
  }

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      budgetAmount: double.tryParse(json['budget_amount'].toString()) ?? 0,
      spentAmount: double.tryParse(json['spent_amount'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'id': id,
      'category_name': categoryName,
      'budget_amount': budgetAmount,
      'spent_amount': spentAmount,
    };
  }

  BudgetCategoryModel copyWith({
    int? id,
    String? categoryName,
    double? budgetAmount,
    double? spentAmount,
  }) {
    return BudgetCategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.month,
    required this.totalBudget,
    required this.totalSpent,
    required this.warningPercentage,
    required this.categoryBudgets,
  });

  final int id;
  final String month;
  final double totalBudget;
  final double totalSpent;
  final int warningPercentage;
  final List<BudgetCategoryModel> categoryBudgets;

  double get remainingBudget {
    final double remaining = totalBudget - totalSpent;
    return remaining < 0 ? 0 : remaining;
  }

  double get overBudgetAmount {
    final double over = totalSpent - totalBudget;
    return over < 0 ? 0 : over;
  }

  bool get isOverBudget => totalSpent > totalBudget;

  double get usedPercentage {
    if (totalBudget <= 0) return 0;

    final double percentage = (totalSpent / totalBudget) * 100;

    if (percentage < 0) return 0;
    if (percentage > 100) return 100;

    return percentage;
  }

  bool get isWarningReached => usedPercentage >= warningPercentage;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> categoryList = json['category_budgets'] ?? [];

    return BudgetModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      month: json['month']?.toString() ?? '',
      totalBudget: double.tryParse(json['total_budget'].toString()) ?? 0,
      totalSpent: double.tryParse(json['total_spent'].toString()) ?? 0,
      warningPercentage:
          int.tryParse(json['warning_percentage'].toString()) ?? 80,
      categoryBudgets: categoryList.map((dynamic item) {
        return BudgetCategoryModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'month': month,
      'total_budget': totalBudget,
      'total_spent': totalSpent,
      'warning_percentage': warningPercentage,
      'category_budgets': categoryBudgets.map((BudgetCategoryModel category) {
        return category.toPayload();
      }).toList(),
    };
  }

  BudgetModel copyWith({
    int? id,
    String? month,
    double? totalBudget,
    double? totalSpent,
    int? warningPercentage,
    List<BudgetCategoryModel>? categoryBudgets,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      warningPercentage: warningPercentage ?? this.warningPercentage,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }
}