
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GrihaLakshmi';
  static const String appTagline = 'Plan your family money with confidence';

  // Currency
  static const String defaultCurrency = '৳';
  static const String defaultCurrencyCode = 'BDT';

  // Date / Month
  static const String defaultMonthFormat = 'MMMM yyyy';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String familyKey = 'family_data';
  static const String languageKey = 'app_language';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Padding
  static const double screenPadding = 24.0;
  static const double cardRadius = 24.0;
  static const double buttonRadius = 16.0;

  // App Categories
  static const List<String> expenseCategories = [
    'Grocery',
    'House Rent',
    'Electricity Bill',
    'Gas Bill',
    'WiFi Bill',
    'Medical',
    'Village Family Support',
    'Shopping',
    'Transport',
    'Education',
    'Others',
  ];

  static const List<String> incomeSources = [
    'Salary',
    'Business',
    'Freelance',
    'Bonus',
    'Gift',
    'Other',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Bank',
    'Card',
    'Mobile Banking',
  ];

  static const List<String> familyRoles = [
    'Husband',
    'Wife',
    'Family Member',
  ];

  static const List<String> languages = [
    'English',
    'Bangla',
  ];
}