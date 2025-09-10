import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatefulWidget {
  final ValueChanged<DateTime>? onMonthChanged;
  final double iconSize;

  const MonthSelector({
    super.key,
    this.onMonthChanged,
    this.iconSize = 24,
  });

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
    widget.onMonthChanged?.call(selectedDate);
  }

  void _openMonthModal(BuildContext context) {
    int tempYear = selectedDate.year;
    int tempMonth = selectedDate.month;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Center(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 10,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barra do ano
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, size: widget.iconSize),
                            color: colorScheme.onSurface,
                            onPressed: () {
                              setModalState(() {
                                tempYear--;
                              });
                            },
                          ),
                          Text(
                            tempYear.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, size: widget.iconSize),
                            color: colorScheme.onSurface,
                            onPressed: () {
                              setModalState(() {
                                tempYear++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grade de meses
                      Wrap(
                        spacing: 24,
                        runSpacing: 5,
                        alignment: WrapAlignment.center,
                        children: List.generate(12, (index) {
                          int month = index + 1;
                          String shortMonth = DateFormat.MMM('pt_BR')
                              .format(DateTime(0, month))
                              .toUpperCase();

                          bool isSelected = (tempMonth == month &&
                              tempYear == selectedDate.year);

                          return Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(40),
                              splashColor: colorScheme.primary.withOpacity(0.3),
                              onTap: () {
                                setState(() {
                                  selectedDate = DateTime(tempYear, month);
                                });
                                widget.onMonthChanged?.call(selectedDate);
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withOpacity(0.9)
                                      : colorScheme.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  shortMonth,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged?.call(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String formattedMonth =
        DateFormat.MMMM('pt_BR').format(selectedDate).capitalize();

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Icon(Icons.chevron_left, size: widget.iconSize),
                splashRadius: 24,
                color: colorScheme.onBackground,
                onPressed: () => _changeMonth(-1),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openMonthModal(context),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                formattedMonth,
                key: ValueKey<String>(formattedMonth),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(Icons.chevron_right, size: widget.iconSize),
                splashRadius: 30,
                color: colorScheme.onBackground,
                onPressed: () => _changeMonth(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extensão para capitalizar primeira letra
extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
