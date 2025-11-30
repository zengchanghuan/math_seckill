import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/math_text.dart';
import '../../../core/models/formula.dart';
import '../controllers/formula_controller.dart';

class FormulaDetailPage extends StatelessWidget {
  final Formula formula;

  const FormulaDetailPage({
    super.key,
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FormulaController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(formula.name),
        actions: [
          Obx(() {
            final isFavorite = controller.isFavorite(formula.id);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                controller.toggleFavorite(formula.id);
                Get.snackbar(
                  isFavorite ? '已取消收藏' : '已收藏',
                  formula.name,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
              },
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标签
            Chip(
              label: Text(formula.category),
              avatar: const Icon(Icons.category, size: 18),
            ),
            const SizedBox(height: 24),

            // 公式展示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: MathText(
                formula.formula,
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 描述
            Text(
              '描述',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formula.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // 应用示例
            Text(
              '应用示例',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: MathText(
                formula.example,
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

