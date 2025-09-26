import 'dart:ui';
import 'package:flutter/material.dart';

class IncomeDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const IncomeDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 9),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          textCapitalization: TextCapitalization.words,
          cursorColor: Colors.blueAccent,
          selectionControls: MaterialTextSelectionControls(),
          selectionHeightStyle: BoxHeightStyle.tight,
          selectionWidthStyle: BoxWidthStyle.tight,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 15, right: 23),
              child: Icon(Icons.description, color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            border: InputBorder.none,
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Campo obrigatório' : null,
        ),
      ),
    );
  }
}
