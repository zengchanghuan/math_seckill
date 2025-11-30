import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';
import '../widgets/problem_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/drill_drawer.dart';
import '../../../core/services/problem_service.dart';

class DrillPage extends StatelessWidget {
  const DrillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DrillController());
    final problemService = Get.find<ProblemService>();

    return Scaffold(
      drawer: const DrillDrawer(),
      appBar: AppBar(
        title: const Text('刷题'),
      ),
      body: Obx(() {
        if (problemService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentProblems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无题目',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请选择其他主题或难度',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        // 初始化 PageController（如果还没有）
        controller.pageController ??= PageController(
          initialPage: controller.currentIndex.value,
        );

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                physics: const AlwaysScrollableScrollPhysics(),
                allowImplicitScrolling: false,
                onPageChanged: (index) {
                  controller.currentIndex.value = index;
                },
                itemCount: controller.currentProblems.length,
                itemBuilder: (context, index) {
                  return ProblemCard(
                    problem: controller.currentProblems[index],
                  );
                },
              ),
            ),
            const ProgressBar(),
          ],
        );
      }),
    );
  }
}

