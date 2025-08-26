import 'package:flutter/material.dart';
import 'package:finc/routes/app_routes.dart';

class FloatingActionButtonsMenu extends StatelessWidget {
  final bool showActionButtons;
  final AnimationController controller;
  final double screenWidth;
  final String userId;
  final VoidCallback onClose;

  const FloatingActionButtonsMenu({
    required this.showActionButtons,
    required this.controller,
    required this.screenWidth,
    required this.userId,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botão Transferência
        _buildButton(
          context,
          bottom: showActionButtons ? 90 : 40,
          left: screenWidth / 2 - 50,
          color: Colors.deepPurple,
          icon: Icons.compare_arrows,
          label: "Transferência",
          route: AppRoutes.transfer,
        ),

        // Botão Despesa
        _buildButton(
          context,
          bottom: 60,
          left: showActionButtons ? screenWidth / 2 - 125 : screenWidth / 2 - 18,
          color: Theme.of(context).colorScheme.tertiary,
          icon: Icons.arrow_downward,
          label: "Despesa",
          route: AppRoutes.addExpense,
        ),

        // Botão Receita
        _buildButton(
          context,
          bottom: 60,
          left: showActionButtons ? screenWidth / 2 + 70 : screenWidth / 2 - 18,
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.arrow_upward,
          label: "Receita",
          route: AppRoutes.addIncome,
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context,
      {required double bottom,
      required double left,
      required Color color,
      required IconData icon,
      required String label,
      required String route}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: bottom,
      left: left,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showActionButtons ? 1 : 0,
        child: Column(
          children: [
            FloatingActionButton(
              heroTag: label,
              backgroundColor: color,
              onPressed: () {
                Navigator.pushNamed(context, route, arguments: userId);
                onClose();
              },
              child: Icon(icon),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
