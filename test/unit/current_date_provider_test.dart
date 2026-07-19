import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/providers/current_date_provider.dart';

void main() {
  group('nextMidnightAfter', () {
    test('returns 1s past the next local midnight for a mid-day time', () {
      final now = DateTime(2026, 7, 19, 14, 30, 15);
      expect(nextMidnightAfter(now), DateTime(2026, 7, 20, 0, 0, 1));
    });

    test('is strictly after now and lands on the following day', () {
      final now = DateTime(2026, 7, 19, 23, 59, 59);
      final next = nextMidnightAfter(now);
      expect(next.isAfter(now), isTrue);
      expect(next, DateTime(2026, 7, 20, 0, 0, 1));
    });

    test('rolls into the next month at month end', () {
      final now = DateTime(2026, 7, 31, 8, 0);
      expect(nextMidnightAfter(now), DateTime(2026, 8, 1, 0, 0, 1));
    });

    test('rolls into the next year at year end', () {
      final now = DateTime(2026, 12, 31, 23, 0);
      expect(nextMidnightAfter(now), DateTime(2027, 1, 1, 0, 0, 1));
    });

    test('delay to the next midnight is always within one day', () {
      final now = DateTime(2026, 7, 19, 0, 0, 1);
      final delay = nextMidnightAfter(now).difference(now);
      expect(delay.inHours, lessThanOrEqualTo(24));
      expect(delay.isNegative, isFalse);
    });
  });
}
