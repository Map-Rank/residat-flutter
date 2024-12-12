import 'package:flutter/material.dart';

class TooltipWidget extends StatelessWidget {
  final String text;

  const TooltipWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            //borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black,width: 0.05),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          bottom: -8, // Adjust to make the triangle blend perfectly
          left: 30, // Adjust to center or align with container
          child: CustomPaint(
            size: const Size(24, 12),
            painter: TooltipTrianglePainter(
              fillColor: Colors.white,
              borderColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class TooltipTrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  TooltipTrianglePainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 0) // Bottom-left corner of the triangle
      ..lineTo(size.width / 2, size.height) // Tip of the triangle
      ..lineTo(size.width, 0) // Bottom-right corner
      ..close();

    canvas.drawPath(path, borderPaint); // Drawing triangle with border color

    Path innerPath = Path()
      ..moveTo(1, 1) // Move slightly inwards to blend with the container
      ..lineTo(size.width / 2, size.height - 1)
      ..lineTo(size.width - 1, 1)
      ..close();

    Paint fillPaint = Paint()..color = fillColor;
    canvas.drawPath(innerPath, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: TooltipWidget(text: 'Some text example!!!!'),
        ),
      ),
    ),
  );
}
