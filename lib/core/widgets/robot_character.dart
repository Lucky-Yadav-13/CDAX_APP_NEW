import 'package:flutter/material.dart';

/// 3D Robot character widget with different expressions
class RobotCharacter extends StatelessWidget {
  const RobotCharacter({
    super.key,
    this.isHappy = true,
    this.size = 80.0,
  });

  final bool isHappy;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Robot body (main circle)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size / 2),
              border: Border.all(
                color: const Color(0xFF87CEEB), // Light blue border
                width: 2,
              ),
            ),
          ),
          // Robot screen/face
          Positioned(
            top: size * 0.15,
            left: size * 0.2,
            right: size * 0.2,
            child: Container(
              height: size * 0.3,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB), // Light blue screen
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size * 0.4, size * 0.15),
                  painter: _RobotFacePainter(isHappy: isHappy),
                ),
              ),
            ),
          ),
          // Antenna
          Positioned(
            top: size * 0.05,
            left: size * 0.45,
            child: Container(
              width: 2,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Antenna tip
          Positioned(
            top: size * 0.02,
            left: size * 0.42,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Left arm
          Positioned(
            left: -size * 0.1,
            top: size * 0.4,
            child: Container(
              width: size * 0.15,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
          // Right arm
          Positioned(
            right: -size * 0.1,
            top: size * 0.4,
            child: Container(
              width: size * 0.15,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotFacePainter extends CustomPainter {
  const _RobotFacePainter({required this.isHappy});

  final bool isHappy;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    if (isHappy) {
      // Happy face - upward curve
      path.moveTo(size.width * 0.2, size.height * 0.6);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9,
        size.width * 0.8,
        size.height * 0.6,
      );
    } else {
      // Sad face - downward curve
      path.moveTo(size.width * 0.2, size.height * 0.4);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.4,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
