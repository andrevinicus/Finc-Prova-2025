import 'package:flutter/material.dart';

class FilterChipCustom extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showTrailingIcon;
  final Color? activeColor;

  const FilterChipCustom({
    Key? key,
    required this.label,
    this.selected = false,
    this.showTrailingIcon = false,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primary = activeColor ?? const Color(0xFFD4AF37); // padrão dourado
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? primary.withOpacity(0.18) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? primary : Colors.black87,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (showTrailingIcon) const SizedBox(width: 8),
          if (showTrailingIcon) const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}
