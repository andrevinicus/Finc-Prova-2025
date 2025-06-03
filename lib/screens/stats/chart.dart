import 'package:expense_repository/expense_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MyChart extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> incomes;

  const MyChart({
    super.key,
    required this.expenses,
    required this.incomes,
  });

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  final _pageController = PageController();
  int _currentPageIndex = 0;
  final List<String> _chartTitles = ["Valores por Dia", "Tendência da Semana"];

  late List<double> expensesPerDay;
  late List<double> incomesPerDay;
  late List<String> dayLabels;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeChartData() {
    expensesPerDay = List.filled(7, 0);
    incomesPerDay = List.filled(7, 0);
    dayLabels = List.filled(7, '');
    _calculateDailyTotals();
  }

  void _calculateDailyTotals() {
    DateTime date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    int weekday = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
    List<DateTime> last7Days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    dayLabels = last7Days.map((d) => DateFormat('d/M').format(d)).toList();
    expensesPerDay = List.filled(7, 0);
    incomesPerDay = List.filled(7, 0);
    for (var e in widget.expenses) {
      for (int i = 0; i < 7; i++) {
        if (_isSameDay(e.date, last7Days[i])) {
          expensesPerDay[i] += e.amount.toDouble();
        }
      }
    }
    for (var i in widget.incomes) {
      for (int j = 0; j < 7; j++) {
        if (_isSameDay(i.date, last7Days[j])) {
          incomesPerDay[j] += i.amount.toDouble();
        }
      }
    }
  }
  
  double get _rawMaxValue {
    double maxExpense = expensesPerDay.isNotEmpty ? expensesPerDay.reduce((a, b) => a > b ? a : b) / 1000 : 0;
    double maxIncome = incomesPerDay.isNotEmpty ? incomesPerDay.reduce((a, b) => a > b ? a : b) / 1000 : 0;
    return (maxExpense > maxIncome ? maxExpense : maxIncome) * 1.1;
  }

  double get yInterval {
    final maxValue = _rawMaxValue;
    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    return 25;
  }

  double get maxY => _roundToNearest(_rawMaxValue, yInterval);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _calculateDailyTotals();
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double _roundToNearest(double value, double interval) {
    return (value / interval).round() * interval;
  }

  Widget _buildBarChartPage() {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label = rodIndex == 0 ? 'Despesa' : 'Receita';
                return BarTooltipItem(
                  '$label\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'R\$ ${(rod.toY * 1000).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: rod.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(dayLabels[value.toInt()]),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize:20,
                interval: yInterval,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}K',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 5, 
                getTitlesWidget: (value, meta) => Text(
                  '',
                  style: const TextStyle(fontSize: 12, color: Colors.transparent),
                ),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 5, 
                getTitlesWidget: (value, meta) {
                  return const Text(
                    '',
                    style: TextStyle(color: Colors.transparent),
                  );
                },
              ),
            ),
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            7,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: expensesPerDay[i] / 1000,
                  width: 8,
                  color: Colors.redAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: incomesPerDay[i] / 1000,
                  width: 8,
                  color: Colors.greenAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ],
              barsSpace: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartPage() {
    final List<FlSpot> expenseSpots = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), expensesPerDay[i] / 1000),
    );
    final List<FlSpot> incomeSpots = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), incomesPerDay[i] / 1000),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.grey.shade800,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(dayLabels[value.toInt()]),
                ),
              ),
            ),
            // CÓDIGO CORRIGIDO
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}K',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // O resto do seu titlesData continua igual...
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 5, 
                getTitlesWidget: (value, meta) => Text(
                  '',
                  style: const TextStyle(fontSize: 12, color: Colors.transparent),
                ),),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 5, 
                getTitlesWidget: (value, meta) {
                  return const Text(
                    '', 
                    style: TextStyle(color: Colors.transparent),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.2)),
            ),
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.greenAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  const Text("Despesas", style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(width: 8, height: 8, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  const Text("Receitas", style: TextStyle(fontSize: 12)),
                ],
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(DateFormat('d MMM').format(selectedDate)),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
              child: Column(
                children: [
                  Padding(
                   padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _chartTitles[_currentPageIndex],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 0),         
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      children: [
                        _buildBarChartPage(),
                        _buildLineChartPage(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
