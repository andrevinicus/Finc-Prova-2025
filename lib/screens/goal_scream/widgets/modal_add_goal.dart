import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/category/constants/category_colors.dart';
import 'package:finc/screens/goal_scream/bloc/events_goal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../bloc/bloc_goal.dart';

class AddGoalModal extends StatefulWidget {
  final GoalBloc goalBloc;
  final void Function(dynamic goal)? onAddGoal;
  final Goal? goalToEdit;

  const AddGoalModal({
    super.key,
    required this.goalBloc,
    this.onAddGoal,
    this.goalToEdit,
  });

  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  late TextEditingController titleController;
  late TextEditingController targetAmountController;
  late TextEditingController descriptionController;

  DateTime? startDate;
  DateTime? endDate;
  Color selectedColor = Colors.blue;
  double monthlySaving = 0;

  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    if (widget.goalToEdit != null) {
      final g = widget.goalToEdit!;
      titleController = TextEditingController(text: g.title);
      targetAmountController = TextEditingController(text: g.targetAmount.toString());
      descriptionController = TextEditingController(text: g.description);
      startDate = g.startDate;
      endDate = g.endDate;
      selectedColor = g.color;
      _calculateMonthlySaving();
    } else {
      titleController = TextEditingController();
      targetAmountController = TextEditingController();
      descriptionController = TextEditingController();
    }
  }

  void _calculateMonthlySaving() {
    final amount = double.tryParse(targetAmountController.text.replaceAll(',', '.')) ?? 0;
    if (amount > 0 && startDate != null && endDate != null) {
      final months = (endDate!.difference(startDate!).inDays / 30).ceil();
      setState(() {
        monthlySaving = months > 0 ? amount / months : amount;
      });
    } else {
      setState(() {
        monthlySaving = 0;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        startDate = date;
        _calculateMonthlySaving();
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        endDate = date;
        _calculateMonthlySaving();
      });
    }
  }

  void _saveGoal() {
    if (titleController.text.isEmpty ||
        targetAmountController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Campos obrigatórios'),
          content: const Text('Por favor, preencha todos os campos obrigatórios.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final amount = double.tryParse(targetAmountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Valor inválido'),
          content: const Text('O valor da meta deve ser maior que zero.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final goal = Goal(
      id: widget.goalToEdit?.id ?? const Uuid().v4(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: titleController.text,
      targetAmount: amount,
      currentAmount: widget.goalToEdit?.currentAmount ?? 0,
      color: selectedColor,
      description: descriptionController.text,
      startDate: startDate!,
      endDate: endDate!,
    );

    if (widget.goalToEdit != null) {
      widget.goalBloc.add(UpdateGoal(goal));
    } else {
      widget.goalBloc.add(AddGoal(goal));
    }

    

    if (widget.onAddGoal != null) widget.onAddGoal!(goal);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.goalToEdit != null ? 'Editar Meta' : 'Adicionar Meta',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da Meta',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Valor Alvo',
                    prefixText: 'R\$ ',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateMonthlySaving(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Ex: Viagem dos sonhos em família',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickStartDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          startDate != null
                              ? DateFormat('dd/MM/yyyy').format(startDate!)
                              : 'Selecionar Início',
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickEndDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          endDate != null
                              ? DateFormat('dd/MM/yyyy').format(endDate!)
                              : 'Selecionar Fim',
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: defaultCategoryColors.map((colorValue) {
                      final color = Color(colorValue);
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (monthlySaving > 0)
                  Text(
                    'Você precisa guardar aproximadamente R\$ ${monthlySaving.toStringAsFixed(2)} por mês',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: selectedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveGoal,
                  child: Text(widget.goalToEdit != null ? 'Salvar Alterações' : 'Adicionar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
