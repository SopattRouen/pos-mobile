import 'package:intl/intl.dart';

void printError({required String? errorMessage, int? statusCode}) {
  final message = errorMessage ?? 'Unknown error';
  final statusText = statusCode != null ? 'Status: $statusCode - ' : '';
}

String formatTimeToHour(String? isoTimestamp) {
  try {
    if (isoTimestamp == null || isoTimestamp.isEmpty) return '...';
    // Parse the ISO 8601 string into a DateTime object
    DateTime dateTime = DateTime.parse(isoTimestamp);

    // Extract hours and minutes
    int hours = dateTime.hour; // 0-23
    int minutes = dateTime.minute;

    // Convert to 12-hour format
    String period = hours >= 12 ? 'PM' : 'AM';
    int displayHours = hours % 12 == 0 ? 12 : hours % 12;

    // Format minutes with leading zero if needed
    String displayMinutes = minutes < 10 ? '0$minutes' : '$minutes';

    // Return formatted time
    return '$displayHours:$displayMinutes $period';
  } catch (e) {
    // Return "..." if parsing fails or any error occurs
    return '...';
  }
}

Map<String, int> convertToHoursAndMinutes(double? value) {
  if (value == null) return {'hours': 0, 'minutes': 0};
  int hours = value.floor();
  int minutes = ((value - hours) * 60).round();
  if (minutes == 60) {
    hours += 1;
    minutes = 0;
  }
  return {'hours': hours, 'minutes': minutes};
}

double clampToZeroOne(double? value) {
  if (value == null) return 0.0;
  if (value < 0.0) return 0.0;
  if (value > 1.0) return 1.0;
  return value;
}

String convertNumberToString(dynamic value) {
  if (value == null) return '';

  if (value is int || value is double) {
    return value.toString();
  }

  return '';
}

int getHoursFromSumHour(dynamic sumHour) {
  try {
    if (sumHour == null) return 0; // Return 0 if input is null
    final double value = double.parse(sumHour.toString()); // Convert to double
    return value.floor(); // Extract integer part (hours)
  } catch (e) {
    return 0; // Return 0 on any error (e.g., invalid format)
  }
}

String formatDate(
  String? dateString, {
  String format = 'dd-mm-yyyy',
}) {
  // Return empty string if date is null or empty
  if (dateString == null || dateString.isEmpty) {
    return '';
  }

  try {
    // Parse the ISO date string
    DateTime dateTime = DateTime.parse(dateString);

    // Format day, month, and year with leading zeros if needed
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();

    // Check which format to use
    switch (format.toLowerCase()) {
      case 'dd/mm/yyyy':
        return '$day/$month/$year';
      case 'dd-mm-yyyy':
      default:
        return '$day-$month-$year';
    }
  } catch (e) {
    // Return N/A if parsing fails
    return 'N/A';
  }
}

String formatStringValue(String? value) {
  // Check if the value is null or empty
  if (value == null || value.trim().isEmpty) {
    return 'N/A';
  }

  // Return the original value if it's valid
  return value;
}

String calculateDateDifference(String? startDatetime, String? endDatetime) {
  // Check if either input is null or empty
  if (startDatetime == null ||
      startDatetime.isEmpty ||
      endDatetime == null ||
      endDatetime.isEmpty) {
    return 'N/A';
  }

  try {
    // Parse the ISO date strings
    DateTime startDate = DateTime.parse(startDatetime);
    DateTime endDate = DateTime.parse(endDatetime);

    // Calculate the difference in days
    int differenceInDays = endDate.difference(startDate).inDays +
        1; // +1 to include both start and end dates

    // Return the result as a string
    return '$differenceInDays ថ្ងៃ'; // Days in Khmer
  } catch (e) {
    // Return N/A if parsing fails
    return 'N/A';
  }
}

String formatTimeTo12Hour(String? timeStr) {
  // Return early if timeStr is null
  if (timeStr == null) return '';

  try {
    // Parse the input time string (e.g., "06:00:00")
    final dateTime = DateTime.parse('1970-01-01 $timeStr');
    // Format to 12-hour with AM/PM, removing leading zero from hour
    return DateFormat('h:mm a').format(dateTime);
  } catch (e) {
    return timeStr; // Return original string if parsing fails
  }
}
