import 'package:flutter/material.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key, required this.courseId, required this.score, required this.total});
  final String courseId;
  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percent = total == 0 ? 0 : (score / total).clamp(0, 1);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Score')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _PiePainter(percent: percent, color: theme.colorScheme.primary),
                    child: Center(
                      child: Text('${(percent * 100).round()}%', style: theme.textTheme.headlineMedium),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Score: $score / $total'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/dashboard/courses/$courseId/assessment/preview', arguments: score);
                  },
                  child: const Text('Go to Certificate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.percent, required this.color});
  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    // Background circle
    canvas.drawCircle(center, radius, backgroundPaint);
    // Foreground arc
    final sweepAngle = 2 * 3.1415926535 * percent;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -3.1415926535 / 2, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => oldDelegate.percent != percent || oldDelegate.color != color;
}


