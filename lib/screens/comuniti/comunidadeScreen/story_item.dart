import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  final String label;
  final String imageUrl;
  final Color? borderColor;

  const StoryItem({
    Key? key,
    required this.label,
    required this.imageUrl,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color border = borderColor ?? Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 2),
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
