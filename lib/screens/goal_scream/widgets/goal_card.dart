import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';


class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // um pouco mais estreito
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goal.color.withOpacity(0.85), goal.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: goal.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // padding reduzido
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100, // menor que antes
              width: 100,
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      value: goal.progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${goal.currentAmount.toStringAsFixed(0)} de R\$ ${goal.targetAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
