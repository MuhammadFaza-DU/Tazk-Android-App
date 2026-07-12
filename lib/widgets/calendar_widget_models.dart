class CalendarWidgetDayCell {
  const CalendarWidgetDayCell({
    required this.date,
    required this.isInVisibleMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasItems,
  });

  final DateTime date;
  final bool isInVisibleMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasItems;

  String get dayLabel => date.day.toString();
}

class CalendarWidgetMonthSnapshot {
  const CalendarWidgetMonthSnapshot({
    required this.visibleMonth,
    required this.selectedDate,
    required this.cells,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<CalendarWidgetDayCell> cells;

  static CalendarWidgetMonthSnapshot build({
    required DateTime visibleMonth,
    required DateTime selectedDate,
    required DateTime today,
    required Set<DateTime> itemDates,
  }) {
    final month = DateTime(visibleMonth.year, visibleMonth.month);
    final selected = _dateOnly(selectedDate);
    final now = _dateOnly(today);
    final normalizedItemDates = itemDates.map(_dateOnly).toSet();
    final firstGridDate = month.subtract(Duration(days: month.weekday - 1));

    final cells = List<CalendarWidgetDayCell>.generate(42, (index) {
      final date = _dateOnly(firstGridDate.add(Duration(days: index)));
      return CalendarWidgetDayCell(
        date: date,
        isInVisibleMonth:
            date.year == month.year && date.month == month.month,
        isToday: date == now,
        isSelected: date == selected,
        hasItems: normalizedItemDates.contains(date),
      );
    });

    return CalendarWidgetMonthSnapshot(
      visibleMonth: month,
      selectedDate: selected,
      cells: cells,
    );
  }

  static DateTime adjacentSelectedDate(DateTime selectedDate, int monthDelta) {
    final targetMonth = DateTime(
      selectedDate.year,
      selectedDate.month + monthDelta,
    );
    final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    final targetDay = selectedDate.day > lastDay ? lastDay : selectedDate.day;
    return DateTime(targetMonth.year, targetMonth.month, targetDay);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
