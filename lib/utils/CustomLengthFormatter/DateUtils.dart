class DateUtils {
  static String formatDateToYYYYDDMM(String date) {
    if (date.isEmpty) {
      return '';
    }
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }
}
