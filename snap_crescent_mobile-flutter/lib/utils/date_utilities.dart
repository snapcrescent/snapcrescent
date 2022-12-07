import 'package:intl/intl.dart';

class DateUtilities {
  static final String timeStampFormat = 'yyyy-MM-dd HH:mm:ss';
  static final String currentWeekFormat = 'EEE';
  static final String currentYearFormat = 'E, MMM dd';
  static final String defaultYearFormat = 'E, MMM dd, yyyy';

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  DateTime getStartOfDayDate() {
    DateTime time = DateTime.now();
    return new DateTime(time.year, time.month, time.day, 0, 0, 0, 0, 0);
  }

  DateTime parseDate(String _dateString, String format) {
    DateTime _date;

    final DateFormat formatter = DateFormat(format);
    _date = formatter.parse(_dateString);

    return _date;
  }

  String formatDate(DateTime? _date, String format) {
    String _formattedDate = "";

    if (_date != null) {
      final DateFormat formatter = DateFormat(format);
      _formattedDate = formatter.format(_date);
    }

    return _formattedDate;
  }
}
