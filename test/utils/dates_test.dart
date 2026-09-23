import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/utils/dates.dart';

void main() {
  final now = DateTime(2026, 9, 23, 18, 30);

  String ago(int days, {int hour = 12}) => formatRelativeDate(
    DateTime(now.year, now.month, now.day - days, hour),
    now,
  );

  group('formatRelativeDate', () {
    test('same day is Today, even earlier or later that day', () {
      expect(ago(0, hour: 0), 'Today');
      expect(ago(0, hour: 23), 'Today');
    });

    test('future dates are treated as Today', () {
      expect(
        formatRelativeDate(now.add(const Duration(days: 3)), now),
        'Today',
      );
    });

    test('previous calendar day is Yesterday regardless of hours', () {
      expect(ago(1, hour: 23), 'Yesterday');
      expect(
        formatRelativeDate(
          DateTime(2026, 9, 22, 23, 59),
          DateTime(2026, 9, 23, 0, 1),
        ),
        'Yesterday',
      );
    });

    test('2 to 6 days', () {
      expect(ago(2), '2 days ago');
      expect(ago(6), '6 days ago');
    });

    test('weeks', () {
      expect(ago(7), '1 week ago');
      expect(ago(13), '1 week ago');
      expect(ago(14), '2 weeks ago');
      expect(ago(30), '4 weeks ago');
    });

    test('months', () {
      expect(ago(31), '1 month ago');
      expect(ago(60), '1 month ago');
      expect(ago(61), '2 months ago');
      expect(ago(364), '12 months ago');
    });

    test('years', () {
      expect(ago(365), '1 year ago');
      expect(ago(729), '1 year ago');
      expect(ago(730), '2 years ago');
    });

    test('crosses month and year boundaries by calendar day', () {
      expect(
        formatRelativeDate(DateTime(2025, 12, 31), DateTime(2026)),
        'Yesterday',
      );
      expect(
        formatRelativeDate(DateTime(2026, 2, 28), DateTime(2026, 3, 2)),
        '2 days ago',
      );
    });
  });
}
