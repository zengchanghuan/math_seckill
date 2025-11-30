import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrillController>();

    return Obx(() {
      final progress = controller.progress;
      final total = controller.totalProblems;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '进度',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '$progress / $total',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: total > 0 ? progress / total : 0,
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    });
  }
}

