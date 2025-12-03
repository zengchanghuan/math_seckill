import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 三角函数单位圆可视化组件
class TrigUnitCircleViz extends StatefulWidget {
  const TrigUnitCircleViz({super.key});

  @override
  State<TrigUnitCircleViz> createState() => _TrigUnitCircleVizState();
}

class _TrigUnitCircleVizState extends State<TrigUnitCircleViz>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = math.pi / 4; // 45度
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          _angle = _controller.value * 2 * math.pi;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sinValue = math.sin(_angle);
    final cosValue = math.cos(_angle);
    final tanValue = math.tan(_angle);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '单位圆与三角函数',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
                  onPressed: _toggleAnimation,
                  tooltip: _isAnimating ? '暂停' : '播放动画',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 单位圆绘制
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: UnitCirclePainter(angle: _angle),
              ),
            ),

            const SizedBox(height: 16),

            // 角度滑块
            Row(
              children: [
                const Text('角度：'),
                Expanded(
                  child: Slider(
                    value: _angle,
                    min: 0,
                    max: 2 * math.pi,
                    onChanged: (value) {
                      setState(() {
                        _angle = value;
                      });
                    },
                  ),
                ),
                Text(
                  '${(_angle * 180 / math.pi).toStringAsFixed(0)}°',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 三角函数值显示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildValueRow('sin θ', sinValue, Colors.red),
                  _buildValueRow('cos θ', cosValue, Colors.green),
                  _buildValueRow('tan θ', tanValue, Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (value + 1) / 2, // 归一化到[0,1]
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              value.abs() > 10 ? '∞' : value.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单位圆绘制器
class UnitCirclePainter extends CustomPainter {
  final double angle;

  UnitCirclePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制坐标轴
    paint.color = Colors.grey.shade300;
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      paint,
    );

    // 绘制单位圆
    paint.color = Colors.blue.shade300;
    canvas.drawCircle(center, radius, paint);

    // 计算点的位置
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy - radius * math.sin(angle); // y轴向下

    // 绘制半径
    paint.color = Colors.black;
    paint.strokeWidth = 2;
    canvas.drawLine(center, Offset(x, y), paint);

    // 绘制sin值（红色竖线）
    paint.color = Colors.red;
    paint.strokeWidth = 3;
    canvas.drawLine(
      Offset(x, y),
      Offset(x, center.dy),
      paint,
    );

    // 绘制cos值（绿色横线）
    paint.color = Colors.green;
    canvas.drawLine(
      center,
      Offset(x, center.dy),
      paint,
    );

    // 绘制角度弧线
    paint.color = Colors.orange.shade300;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.3),
      0,
      -angle,
      false,
      paint,
    );

    // 绘制点
    paint.color = Colors.blue.shade700;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 6, paint);

    // 绘制标签
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // sin标签
    textPainter.text = TextSpan(
      text: 'sin',
      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 10, (y + center.dy) / 2 - 10));

    // cos标签
    textPainter.text = TextSpan(
      text: 'cos',
      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((x + center.dx) / 2 - 15, center.dy + 10));
  }

  @override
  bool shouldRepaint(UnitCirclePainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}

