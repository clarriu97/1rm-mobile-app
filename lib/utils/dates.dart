import '../l10n/app_localizations.dart';

/// Human "how long ago" for a training date, relative to [now].
/// Compares calendar days, so 23:59 yesterday is "Yesterday" at 00:01.
String formatRelativeDate(DateTime date, DateTime now, AppLocalizations l10n) {
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (days <= 0) return l10n.today;
  if (days == 1) return l10n.yesterday;
  if (days < 7) return l10n.daysAgo(days);
  if (days < 14) return l10n.weeksAgo(1);
  if (days < 31) return l10n.weeksAgo(days ~/ 7);
  if (days < 61) return l10n.monthsAgo(1);
  if (days < 365) return l10n.monthsAgo(days ~/ 30);
  return l10n.yearsAgo(days < 730 ? 1 : days ~/ 365);
}
