import 'package:flutter/material.dart';

Future<String?> showAccountTypeModal(BuildContext context) async {
  final accountTypes = [
    'Conta Corrente',
    'Carteira',
    'Poupança',
    'Investimentos',
    'VR/VA',
    'Outros',
  ];

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tipo da Conta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...accountTypes.map(
            (type) => ListTile(
              title: Text(type, style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, type),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}
