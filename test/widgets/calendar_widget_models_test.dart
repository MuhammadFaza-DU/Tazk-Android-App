import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/widgets/calendar_widget_models.dart';

void main() {
  test('builds a fixed 42-cell grid for the visible month', () {
    final snapshot = CalendarWidgetMonthSnapshot.build(
      visibleMonth: DateTime(2026, 7),
      selectedDate: DateTime(2026, 7, 11),
      today: DateTime(2026, 7, 11),
      itemDates: const {},
    );

    expect(snapshot.cells, hasLength(42));
    expect(snapshot.cells.first.date, DateTime(2026, 6, 29));
    expect(snapshot.cells[2].date, DateTime(2026, 7, 1));
    expect(snapshot.cells.last.date, DateTime(2026, 8, 9));
    expect(snapshot.cells[2].isInVisibleMonth, isTrue);
    expect(snapshot.cells.first.isInVisibleMonth, isFalse);
  });

  test('marks selected date, today, and dates with items', () {
    final snapshot = CalendarWidgetMonthSnapshot.build(
      visibleMonth: DateTime(2026, 7),
      selectedDate: DateTime(2026, 7, 12),
      today: DateTime(2026, 7, 11),
      itemDates: {
        DateTime(2026, 7, 12),
        DateTime(2026, 7, 20),
      },
    );

    final selected = snapshot.cells.singleWhere(
      (cell) => cell.date == DateTime(2026, 7, 12),
    );
    final today = snapshot.cells.singleWhere(
      (cell) => cell.date == DateTime(2026, 7, 11),
    );
    final itemDate = snapshot.cells.singleWhere(
      (cell) => cell.date == DateTime(2026, 7, 20),
    );

    expect(selected.isSelected, isTrue);
    expect(selected.hasItems, isTrue);
    expect(today.isToday, isTrue);
    expect(today.isSelected, isFalse);
    expect(itemDate.hasItems, isTrue);
  });

  test('moves to adjacent months while keeping selected day in range', () {
    final current = DateTime(2026, 1, 31);

    expect(
      CalendarWidgetMonthSnapshot.adjacentSelectedDate(current, 1),
      DateTime(2026, 2, 28),
    );
    expect(
      CalendarWidgetMonthSnapshot.adjacentSelectedDate(current, -1),
      DateTime(2025, 12, 31),
    );
  });
}
