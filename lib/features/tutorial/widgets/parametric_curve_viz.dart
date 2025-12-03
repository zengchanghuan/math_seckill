import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 参数方程轨迹可视化组件
class ParametricCurveViz extends StatefulWidget {
  const ParametricCurveViz({super.key});

  @override
  State<ParametricCurveViz> createState() => _ParametricCurveVizState();
}

class _ParametricCurveVizState extends State<ParametricCurveViz>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _trail = [];
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        setState(() {
          _t = _controller.value * 4 * math.pi;
          _updateTrail();
        });
      });
  }

  void _updateTrail() {
    final x = 3 * math.cos(_t);
    final y = 3 * math.sin(_t);
    _trail.add(Offset(x, y));
    if (_trail.length > 200) {
      _trail.removeAt(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = 3 * math.cos(_t);
    final y = 3 * math.sin(_t);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '参数方程轨迹',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _trail.clear();
                          _controller.reset();
                        });
                      },
                      tooltip: '重置',
                    ),
                    IconButton(
                      icon: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        if (_controller.isAnimating) {
                          _controller.stop();
                        } else {
                          _controller.forward();
                        }
                      },
                      tooltip: _controller.isAnimating ? '暂停' : '播放',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 参数方程显示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text(
                    '参数方程：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('x = 3cos(t)'),
                  Text('y = 3sin(t)'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 轨迹绘制
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: ParametricCurvePainter(
                  currentPoint: Offset(x, y),
                  trail: _trail,
                  t: _t,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 当前位置
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('t = ${_t.toStringAsFixed(2)}'),
                  Text('x = ${x.toStringAsFixed(2)}'),
                  Text('y = ${y.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 参数曲线绘制器
class ParametricCurvePainter extends CustomPainter {
  final Offset currentPoint;
  final List<Offset> trail;
  final double t;

  ParametricCurvePainter({
    required this.currentPoint,
    required this.trail,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 8;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制坐标轴
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);

    // 绘制轨迹
    if (trail.length > 1) {
      paint.color = Colors.blue.shade300;
      paint.strokeWidth = 2;
      final path = Path();
      final firstPoint = Offset(
        center.dx + trail.first.dx * scale,
        center.dy - trail.first.dy * scale,
      );
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (final point in trail.skip(1)) {
        final scaledPoint = Offset(
          center.dx + point.dx * scale,
          center.dy - point.dy * scale,
        );
        path.lineTo(scaledPoint.dx, scaledPoint.dy);
      }
      canvas.drawPath(path, paint);
    }

    // 绘制当前点
    final pointPos = Offset(
      center.dx + currentPoint.dx * scale,
      center.dy - currentPoint.dy * scale,
    );
    paint.color = Colors.red.shade700;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(pointPos, 6, paint);

    // 绘制从原点到当前点的向量
    paint.color = Colors.purple.shade400;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawLine(center, pointPos, paint);

    // 绘制坐标轴标签
    _drawText(canvas, 'x', Offset(size.width - 20, center.dy + 20), Colors.black);
    _drawText(canvas, 'y', Offset(center.dx + 10, 15), Colors.black);
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(ParametricCurvePainter oldDelegate) => true;
}


