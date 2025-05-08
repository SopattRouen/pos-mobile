import 'package:intl/intl.dart';

DateTime getStartDate(String period) {
  DateTime now = DateTime.now();
  if (period == 'Today') {
    // Today
    return DateTime(now.year, now.month, now.day);
  } else if (period == 'This Week') {
    // This week
    // This week - get the start of the current week (Monday)
    int daysSinceMonday = now.weekday - DateTime.monday;
    return now.subtract(Duration(days: daysSinceMonday));
  } else if (period == 'Yesterday') {
    return DateTime(now.year, now.month, now.day - 1);
  } else if (period == 'This Month') {
    // This month
    return DateTime(now.year, now.month, 1);
  } else if (period == '3 Month Ago') {
    // 3 months ago
    return DateTime(now.year, now.month - 3, 1);
  } else if (period == '6 Month Ago') {
    // 6 months ago
    return DateTime(now.year, now.month - 6, 1);
  }
  return now; // default to now if no match
}

DateTime getEndDate(String period) {
  DateTime now = DateTime.now();
  if (period == 'Today') {
    return DateTime(now.year, now.month, now.day);
  } else if (period == 'This Week') {
    return now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
  } else if (period == 'This Month') {
    return DateTime(now.year, now.month + 1, 0);
  } else if (period == '3 Month Ago') {
    return DateTime(now.year, now.month - 1, 0);
  } else if (period == '6 Month Ago') {
    return DateTime(now.year, now.month - 4, 0);
  }
  return now;
}

int weekOfYear(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

String formatDates(String title, DateTime startDate, DateTime endDate) {
  if (title == "Today") {
    return formatDate(startDate); // Just return the start date if it's today.
  } else {
    final DateFormat formatter = DateFormat('d/M/y');
    return '${formatter.format(startDate)} to ${formatter.format(endDate)}';
  }
}

String formatDate(DateTime date) {
  return DateFormat('d-M-y').format(date);
}
