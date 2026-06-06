class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User / Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String changePassword = '/profile/change-password';

  // Family
  static const String families = '/families';
  static const String createFamily = '/families';
  static const String joinFamily = '/families/join';
  static const String familyMembers = '/families/members';
  static const String inviteMember = '/families/invite';

  // Income
  static const String incomes = '/incomes';
  static const String storeIncome = '/incomes';
  static String incomeDetails(int id) => '/incomes/$id';
  static String updateIncome(int id) => '/incomes/$id';
  static String deleteIncome(int id) => '/incomes/$id';

  // Expense
  static const String expenses = '/expenses';
  static const String storeExpense = '/expenses';
  static String expenseDetails(int id) => '/expenses/$id';
  static String updateExpense(int id) => '/expenses/$id';
  static String deleteExpense(int id) => '/expenses/$id';


  // Purchase Planner
  static const String purchasePlannerItems = '/purchase-planner/items';
  static const String storePurchasePlannerItem = '/purchase-planner/items';

  static String updatePurchasePlannerItem(int id) => '/purchase-planner/items/$id';

  static String deletePurchasePlannerItem(int id) => '/purchase-planner/items/$id';

  static String assignPurchasePlannerItem(int id) => '/purchase-planner/items/$id/assign';

  static String markPurchasePlannerItemPurchased(int id) => '/purchase-planner/items/$id/mark-purchased';

  static String cancelPurchasePlannerItem(int id) => '/purchase-planner/items/$id/cancel';

  // Bills
  static const String bills = '/bills';
  static const String storeBill = '/bills';
  static String billDetails(int id) => '/bills/$id';
  static String updateBill(int id) => '/bills/$id';
  static String deleteBill(int id) => '/bills/$id';
  static String markBillAsPaid(int id) => '/bills/$id/mark-as-paid';

  // Savings Goal
  static const String savingsGoals = '/savings-goals';
  static const String createSavingsGoal = '/savings-goals';
  static String savingsGoalDetails(int id) => '/savings-goals/$id';
  static String updateSavingsGoal(int id) => '/savings-goals/$id';
  static String deleteSavingsGoal(int id) => '/savings-goals/$id';

  // Dashboard / Reports
  static const String dashboard = '/dashboard';
  static const String monthlyReport = '/reports/monthly';
  static const String categoryReport = '/reports/categories';


  // Notifications
  static const String notifications = '/notifications';
  static const String markAllNotificationsAsRead = '/notifications/mark-all-read';
  static String markNotificationAsRead(int id) => '/notifications/$id/mark-as-read';

  static const String transactions = '/transactions';
}