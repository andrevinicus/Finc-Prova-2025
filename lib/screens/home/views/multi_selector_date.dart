import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatefulWidget {
  final ValueChanged<DateTime>? onMonthChanged;

  const MonthSelector({super.key, this.onMonthChanged});

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  DateTime selectedDate = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + offset,
      );
    });

    // Notifica o mês atualizado
    widget.onMonthChanged?.call(selectedDate);
  }

@override
void initState() {
  super.initState();
  // Notifica mês atual ao iniciar, mas após o primeiro frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.onMonthChanged?.call(selectedDate);
  });
}

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat.MMMM('pt_BR').format(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          formattedMonth[0].toUpperCase() + formattedMonth.substring(1),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }
}
