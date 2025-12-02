import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';
import '../../../core/services/problem_service.dart';

class DrillDrawer extends StatelessWidget {
  const DrillDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrillController>();
    final problemService = Get.find<ProblemService>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 头部
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  '刷题设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 主题选择
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text('主题选择'),
            children: [
              Obx(() => RadioListTile<String>(
                    title: const Text('全部主题'),
                    value: '全部',
                    groupValue: controller.selectedTopic.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setTopic(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              ...problemService.getAllTopics().map((topic) {
                return Obx(() => RadioListTile<String>(
                      title: Text(topic),
                      value: topic,
                      groupValue: controller.selectedTopic.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setTopic(value);
                          Navigator.pop(context);
                        }
                      },
                    ));
              }),
            ],
          ),

          // 难度选择
          ExpansionTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('难度选择'),
            children: [
              Obx(() => RadioListTile<String>(
                    title: const Text('全部难度'),
                    value: '全部',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              Obx(() => RadioListTile<String>(
                    title: const Text('L1 基础题'),
                    value: 'L1',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              Obx(() => RadioListTile<String>(
                    title: const Text('L2 提升题'),
                    value: 'L2',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              Obx(() => RadioListTile<String>(
                    title: const Text('L3 挑战题'),
                    value: 'L3',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              // 保留旧格式兼容
              Obx(() => RadioListTile<String>(
                    title: const Text('基础 (旧)'),
                    value: '基础',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
              Obx(() => RadioListTile<String>(
                    title: const Text('进阶 (旧)'),
                    value: '进阶',
                    groupValue: controller.selectedDifficulty.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDifficulty(value);
                        Navigator.pop(context);
                      }
                    },
                  )),
            ],
          ),

          const Divider(),

          // 统计信息
          Obx(() {
            final stats = controller.userStats.value;
            return ExpansionTile(
              leading: const Icon(Icons.analytics),
              title: const Text('统计信息'),
              children: [
                ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.blue),
                  title: const Text('总答题数'),
                  trailing: Text(
                    '${stats.totalProblems}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('正确数'),
                  trailing: Text(
                    '${stats.correctCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('错误数'),
                  trailing: Text(
                    '${stats.wrongCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.percent, color: Colors.orange),
                  title: const Text('正确率'),
                  trailing: Text(
                    stats.totalProblems > 0
                        ? '${(stats.accuracy * 100).toStringAsFixed(1)}%'
                        : '0%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            );
          }),

          const Divider(),

          // 当前进度
          Obx(() {
            final progress = controller.progress;
            final total = controller.totalProblems;
            return ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('当前进度'),
              subtitle: Text('已完成 $progress / $total 题'),
              trailing: CircularProgressIndicator(
                value: total > 0 ? progress / total : 0,
                backgroundColor: Colors.grey.shade300,
              ),
            );
          }),

          const Divider(),

          // 错题本
          Obx(() {
            final wrongCount = controller.wrongProblemIds.length;
            return ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: const Text('错题本'),
              subtitle: Text('共 $wrongCount 道错题'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                // 可以导航到错题本页面
              },
            );
          }),

          const Divider(),

          // 重置进度
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text('重置当前进度'),
            onTap: () {
              Navigator.pop(context);
              Get.dialog(
                AlertDialog(
                  title: const Text('确认重置'),
                  content: const Text('确定要重置当前刷题进度吗？这将清空所有答案记录。'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.userAnswers.clear();
                        controller.answerStatus.clear();
                        controller.showSolution.clear();
                        controller.currentIndex.value = 0;
                        if (controller.pageController != null) {
                          controller.pageController!.jumpToPage(0);
                        }
                        Get.back();
                      },
                      child:
                          const Text('确定', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
