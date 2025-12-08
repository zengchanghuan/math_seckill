import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 复数复平面可视化组件
class ComplexPlaneViz extends StatefulWidget {
  const ComplexPlaneViz({super.key});

  @override
  State<ComplexPlaneViz> createState() => _ComplexPlaneVizState();
}

class _ComplexPlaneVizState extends State<ComplexPlaneViz>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _real = 3.0;
  double _imaginary = 4.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          final angle = _controller.value * 2 * math.pi;
          final modulus = math.sqrt(_real * _real + _imaginary * _imaginary);
          _real = modulus * math.cos(angle);
          _imaginary = modulus * math.sin(angle);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modulus = math.sqrt(_real * _real + _imaginary * _imaginary);
    final argument = math.atan2(_imaginary, _real) * 180 / math.pi;

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
                  '复平面与复数',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                      _controller.isAnimating ? Icons.pause : Icons.refresh),
                  onPressed: () {
                    if (_controller.isAnimating) {
                      _controller.stop();
                    } else {
                      _controller.repeat();
                    }
                  },
                  tooltip: _controller.isAnimating ? '停止旋转' : '开始旋转',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 复平面绘制
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: ComplexPlanePainter(
                  real: _real,
                  imaginary: _imaginary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 复数表示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'z = ${_real.toStringAsFixed(2)} + ${_imaginary.toStringAsFixed(2)}i',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip('模', '|z| = ${modulus.toStringAsFixed(2)}',
                          Colors.blue),
                      _buildInfoChip('辐角',
                          'θ = ${argument.toStringAsFixed(0)}°', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 实部虚部滑块
            _buildSlider('实部 Re(z)', _real, -5, 5, (val) {
              setState(() => _real = val);
            }),
            _buildSlider('虚部 Im(z)', _imaginary, -5, 5, (val) {
              setState(() => _imaginary = val);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Chip(
      label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// 复平面绘制器
class ComplexPlanePainter extends CustomPainter {
  final double real;
  final double imaginary;

  ComplexPlanePainter({required this.real, required this.imaginary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 12; // 缩放比例

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 绘制坐标轴
    paint.color = Colors.grey.shade400;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), paint);

    // 绘制网格
    paint.color = Colors.grey.shade200;
    for (int i = -5; i <= 5; i++) {
      if (i == 0) continue;
      canvas.drawLine(
        Offset(center.dx + i * scale, 0),
        Offset(center.dx + i * scale, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, center.dy + i * scale),
        Offset(size.width, center.dy + i * scale),
        paint,
      );
    }

    // 复数对应的点
    final point = Offset(
      center.dx + real * scale,
      center.dy - imaginary * scale,
    );

    // 绘制向量（从原点到复数点）
    paint.color = Colors.purple.shade700;
    paint.strokeWidth = 3;
    canvas.drawLine(center, point, paint);

    // 绘制实部投影（绿色）
    paint.color = Colors.green.shade600;
    paint.strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(point.dx, center.dy),
      paint,
    );

    // 绘制虚部投影（红色）
    paint.color = Colors.red.shade600;
    canvas.drawLine(
      Offset(point.dx, center.dy),
      point,
      paint,
    );

    // 绘制角度弧线
    final modulus = math.sqrt(real * real + imaginary * imaginary);
    if (modulus > 0.1) {
      paint.color = Colors.orange.shade400;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      final argument = math.atan2(imaginary, real);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: scale * 1.5),
        0,
        -argument,
        false,
        paint,
      );
    }

    // 绘制复数点
    paint.color = Colors.purple.shade700;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(point, 6, paint);

    // 绘制坐标轴标签
    _drawText(
        canvas, 'Re', Offset(size.width - 25, center.dy - 20), Colors.black);
    _drawText(canvas, 'Im', Offset(center.dx + 10, 15), Colors.black);
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(ComplexPlanePainter oldDelegate) {
    return oldDelegate.real != real || oldDelegate.imaginary != imaginary;
  }
}





