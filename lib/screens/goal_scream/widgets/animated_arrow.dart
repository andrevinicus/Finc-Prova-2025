import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedArrow extends StatefulWidget {
  const AnimatedArrow({super.key});

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final plusSize = 80.0;

    // "+" grande no centro acima do texto
    final plusX = screenWidth / 2 - plusSize / 2;
    final plusY = screenHeight / 2 - 80;

    // botão + real no canto superior direito (AppBar)
    final buttonX = screenWidth - 40;
    final buttonY = 16.0;

    // seta proporcional (60% do tamanho original)
    final arrowWidth = (buttonX - plusX) * 0.6;
    final arrowHeight = (plusY - buttonY) * 0.6;

    return Stack(
      children: [
        // "+" grande e transparente
        Positioned(
          top: plusY + -110,
          left: plusX,
          child: Icon(
            Icons.add,
            size: plusSize,
            color: Colors.blueAccent.withOpacity(0.2),
          ),
        ),
        // seta animada
        Positioned(
          top: buttonY,
          left: plusX + 80,
          child: SizedBox(
            width: arrowWidth,
            height: arrowHeight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: DiagonalArrowPainter(
                    progress: _controller.value,
                    startX: 0,
                    startY: arrowHeight,
                    endX: arrowWidth,
                    endY: 0,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DiagonalArrowPainter extends CustomPainter {
  final double progress;
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  DiagonalArrowPainter({
    required this.progress,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Traçado curvado animado
    final midX = (startX + endX) / 2 + 30 * math.sin(progress * math.pi);
    final midY = (startY + endY) / 2;

    path.moveTo(startX, startY);
    path.quadraticBezierTo(midX, midY, endX, endY);

    // Cabeça da seta
    const arrowSize = 15.0;
    final angle = math.atan2(endY - midY, endX - midX);

    path.moveTo(endX, endY);
    path.lineTo(
      endX - arrowSize * math.cos(angle - math.pi / 6),
      endY - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.moveTo(endX, endY);
    path.lineTo(
      endX - arrowSize * math.cos(angle + math.pi / 5),
      endY - arrowSize * math.sin(angle + math.pi / 6),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DiagonalArrowPainter oldDelegate) => true;
}
