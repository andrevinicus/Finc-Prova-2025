import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class GoalListItem extends StatefulWidget {
  final Goal goal;
  final bool isExpanded;
  final VoidCallback onTap;

  const GoalListItem({
    super.key,
    required this.goal,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<GoalListItem> createState() => _GoalListItemState();
}

class _GoalListItemState extends State<GoalListItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant GoalListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Limita o progresso de 0 a 1
    final progress = (widget.goal.currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);

    // Dados para o PieChart
    final dataMap = {
      "Concluído": progress * widget.goal.targetAmount,
      "Restante": widget.goal.targetAmount - (progress * widget.goal.targetAmount),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: widget.goal.color,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(widget.goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'R\$ ${widget.goal.currentAmount.toStringAsFixed(0)} de R\$ ${widget.goal.targetAmount.toStringAsFixed(0)}',
            ),
            trailing: RotationTransition(
              turns: _arrowAnimation,
              child: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
            onTap: widget.onTap,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: SizedBox(
                      height: 150,
                      child: PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 20,
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: false,
                        ),
                        colorList: [widget.goal.color, Colors.grey[300]!],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
