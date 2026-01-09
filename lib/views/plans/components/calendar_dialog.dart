import 'package:flutter/material.dart';

class CalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;

  const CalendarDialog({
    Key? key,
    required this.initialDate,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDate = today;
      _currentMonth = DateTime(today.year, today.month);
    });
    widget.onDateSelected?.call(today);
  }

  void _selectCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    setState(() {
      _selectedDate = startOfWeek;
      _currentMonth = DateTime(startOfWeek.year, startOfWeek.month);
    });
    widget.onDateSelected?.call(startOfWeek);
  }

  String _getMonthYearText() {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${months[_currentMonth.month - 1]}, ${_currentMonth.year}';
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );

    // Vietnamese week starts from Monday (T2)
    final firstWeekday = firstDayOfMonth.weekday; // Monday = 1, Sunday = 7
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add previous month's trailing days
    final daysInPrevMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;

    for (int i = firstWeekday - 1; i > 0; i--) {
      final day = daysInPrevMonth - i + 1;
      dayWidgets.add(
        _buildDayCell(day, isCurrentMonth: false, isPrevMonth: true),
      );
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(_buildDayCell(day, isCurrentMonth: true));
    }

    // Add next month's leading days to complete the grid
    final remainingCells = 42 - dayWidgets.length; // 6 rows × 7 days
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(
        _buildDayCell(day, isCurrentMonth: false, isPrevMonth: false),
      );
    }

    return dayWidgets;
  }

  Widget _buildDayCell(
    int day, {
    required bool isCurrentMonth,
    bool isPrevMonth = false,
  }) {
    DateTime cellDate;
    if (isCurrentMonth) {
      cellDate = DateTime(_currentMonth.year, _currentMonth.month, day);
    } else if (isPrevMonth) {
      cellDate = DateTime(_currentMonth.year, _currentMonth.month - 1, day);
    } else {
      cellDate = DateTime(_currentMonth.year, _currentMonth.month + 1, day);
    }

    final isSelected =
        _selectedDate != null &&
        cellDate.year == _selectedDate!.year &&
        cellDate.month == _selectedDate!.month &&
        cellDate.day == _selectedDate!.day;

    final isToday =
        cellDate.year == DateTime.now().year &&
        cellDate.month == DateTime.now().month &&
        cellDate.day == DateTime.now().day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = cellDate;
        });
        widget.onDateSelected?.call(cellDate);
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                  ? Colors.black87
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _goToPreviousMonth,
                  icon: const Icon(Icons.chevron_left, size: 24),
                ),
                Text(
                  _getMonthYearText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: _goToNextMonth,
                  icon: const Icon(Icons.chevron_right, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday headers
            Row(
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            SizedBox(
              height: 240, // 6 rows × 40px height
              child: GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _buildCalendarDays(),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _selectToday,
                    child: const Text(
                      'Hôm nay',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _selectCurrentWeek,
                    child: const Text(
                      'Tuần hiện tại',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Bottom note
            Text(
              'Gọi ý: Chạm vào Ô Thứ Hai để chọn tuần.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
