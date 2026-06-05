class DateHelper {
  DateHelper._();

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Format: 05/06/2026
  static String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();

    return '$day/$month/$year';
  }

  /// Format: 2026-06-05
  /// Useful for API request payload.
  static String formatApiDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();

    return '$year-$month-$day';
  }

  /// Format: 05 Jun 2026
  static String formatReadableDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = _shortMonthNames[date.month - 1];
    final String year = date.year.toString();

    return '$day $month $year';
  }

  /// Format: June 2026
  static String formatMonthYear(DateTime date) {
    final String month = _monthNames[date.month - 1];
    final String year = date.year.toString();

    return '$month $year';
  }

  /// Format: Today, Yesterday, or 05 Jun 2026
  static String formatSmartDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(date.year, date.month, date.day);

    final int difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == -1) {
      return 'Yesterday';
    }

    if (difference == 1) {
      return 'Tomorrow';
    }

    return formatReadableDate(date);
  }

  /// Example: Due in 3 days, Due today, Overdue by 2 days
  static String formatDueStatus(DateTime dueDate) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final int difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Due today';
    }

    if (difference == 1) {
      return 'Due tomorrow';
    }

    if (difference > 1) {
      return 'Due in $difference days';
    }

    if (difference == -1) {
      return 'Overdue by 1 day';
    }

    return 'Overdue by ${difference.abs()} days';
  }

  /// Returns true if bill/expense date is due soon.
  static bool isDueSoon(
    DateTime dueDate, {
    int withinDays = 3,
  }) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final int difference = targetDate.difference(today).inDays;

    return difference >= 0 && difference <= withinDays;
  }

  static bool isOverdue(DateTime dueDate) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    return targetDate.isBefore(today);
  }

  static DateTime? parseApiDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  /// Supports dd/mm/yyyy
  static DateTime? parseDisplayDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final List<String> parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  static bool isSameDate(DateTime firstDate, DateTime secondDate) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }
}