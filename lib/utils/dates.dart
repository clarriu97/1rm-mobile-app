/// Human "how long ago" for a training date, relative to [now].
/// Compares calendar days, so 23:59 yesterday is "Yesterday" at 00:01.
String formatRelativeDate(DateTime date, DateTime now) {
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  if (days < 14) return '1 week ago';
  if (days < 31) return '${days ~/ 7} weeks ago';
  if (days < 61) return '1 month ago';
  if (days < 365) return '${days ~/ 30} months ago';
  return days < 730 ? '1 year ago' : '${days ~/ 365} years ago';
}
