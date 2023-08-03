import 'package:intl/intl.dart';

class DateUtilities {
  static const String timeStampFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String currentWeekFormat = 'EEE';
  static const String currentYearFormat = 'E, MMM dd';
  static const String defaultYearFormat = 'E, MMM dd, yyyy';

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

  bool isBefore(DateTime source, DateTime target) {
      return calculateMinutesBetween(source, target) > 0;
  }

  int calculateMinutesBetween(DateTime source, DateTime target) {
    return (((target.millisecondsSinceEpoch - source.millisecondsSinceEpoch)/1000)/60).floor();
  }

  DateTime getStartOfDayDate() {
    DateTime time = DateTime.now();
    return DateTime(time.year, time.month, time.day, 0, 0, 0, 0, 0);
  }

  DateTime parseDate(String dateString, String format) {
    DateTime date;

    final DateFormat formatter = DateFormat(format);
    date = formatter.parse(dateString);

    return date;
  }

  String formatDate(DateTime? date, String format) {
    String formattedDate = "";

    if (date != null) {
      final DateFormat formatter = DateFormat(format);
      formattedDate = formatter.format(date);
    }

    return formattedDate;
  }

  String getDurationString(int input) {

      String durationString = "";

      double duration = input.toDouble();
      double fraction = 0;
      String fractionString = "";

      if(duration > 3600) {
        fraction = duration / 3600;
        fractionString = zeroFill(fraction.floor().toStringAsFixed(0),2);
        duration = duration  % 3600;
        durationString = '''$durationString$fractionString:''';
      }
      
      fraction = duration / 60;
      fractionString = zeroFill(fraction.floor().toStringAsFixed(0),2);
      duration = duration  % 60;
      durationString = '''$durationString$fractionString:''';
      
      fractionString = zeroFill(duration.toStringAsFixed(0),2);
      durationString = '''$durationString$fractionString''';

      return durationString;
  }

  String zeroFill(String input, int finalLength) {
    for (int i = input.length; i < finalLength; i++) {
        input = '''0$input''';
    }

    return input;
  }
}
