import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';
import '../../../widgets/math_text.dart';
import '../widgets/drill_drawer.dart';
import '../widgets/chapter_selector_tabs.dart';

/// 刷题页面
class DrillPage extends GetView<DrillController> {
  const DrillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('刷题训练'),
        actions: [
          // 统计信息
          Obx(() => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${controller.correctCount.value}/${controller.totalAnswered.value}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
          // 重置按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Get.defaultDialog(
                title: '确认重置',
                middleText: '是否重置统计数据？',
                textConfirm: '确认',
                textCancel: '取消',
                onConfirm: () {
                  controller.resetStats();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      drawer: const DrillDrawer(), // 添加侧边栏
      body: Column(
        children: [
          // 当前主题和章节信息显示
          Obx(() {
            final chapterConfig = controller.getCurrentChapterConfig();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.selectedTheme.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (chapterConfig != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            '${chapterConfig.chapterName} · ${chapterConfig.suggestedQuestions}题 · ${chapterConfig.importance}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),

          // 章节选择器（标签页样式）
          const ChapterSelectorTabs(),
          const Divider(height: 1),

          // 题目内容
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.questions.isEmpty) {
                return const Center(
                  child: Text('暂无题目，请调整筛选条件'),
                );
              }

              return _buildQuestionCard(context);
            }),
          ),

          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// 构建题目卡片
  Widget _buildQuestionCard(BuildContext context) {
    return Obx(() {
      final question = controller.currentQuestion;
      if (question == null) return const SizedBox();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 题目信息栏
            _buildQuestionInfo(question),
            const SizedBox(height: 16),

            // 题目内容
            Card(
              elevation: 2,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MathText(
                        question.question,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 选项（如果是选择题）
            if (question.type == 'choice' && question.options != null)
              ..._buildOptions(question.options!),

            // 填空题或解答题输入框
            if (question.type != 'choice') _buildAnswerInput(),

            const SizedBox(height: 16),

            // 提交后的反馈
            Obx(() {
              if (!controller.isSubmitted.value) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 正确/错误提示
                  Card(
                    color: controller.isCorrect.value
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            controller.isCorrect.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: controller.isCorrect.value
                                ? Colors.green
                                : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.isCorrect.value ? '回答正确！' : '回答错误',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: controller.isCorrect.value
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                if (!controller.isCorrect.value)
                                  Text('正确答案：${question.answer}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 解析
                  Obx(() {
                    if (controller.showSolution.value) {
                      return Card(
                        elevation: 2,
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb,
                                      color: Colors.amber.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '题目解析',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: MathText(
                                  question.solution,
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return ElevatedButton.icon(
                        onPressed: controller.toggleSolution,
                        icon: const Icon(Icons.visibility),
                        label: const Text('查看解析'),
                      );
                    }
                  }),
                ],
              );
            }),
          ],
        ),
      );
    });
  }

  /// 构建题目信息栏
  Widget _buildQuestionInfo(question) {
    return Row(
      children: [
        Obx(() => Text(
              '第 ${controller.currentIndex.value + 1}/${controller.questions.length} 题',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )),
        const SizedBox(width: 16),
        Chip(
          label: Text(question.difficulty),
          backgroundColor: _getDifficultyColor(question.difficulty),
        ),
        const SizedBox(width: 8),
        Chip(label: Text(question.topic)),
      ],
    );
  }

  /// 构建选项列表
  List<Widget> _buildOptions(List<String> options) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return List.generate(options.length, (index) {
      final letter = letters[index];
      final option = options[index];

      return Obx(() {
        final isSelected = controller.userAnswer.value == letter;
        final isSubmitted = controller.isSubmitted.value;
        final correctAnswer = controller.currentQuestion?.answer ?? '';
        final isCorrect = letter == correctAnswer;

        Color? backgroundColor;
        if (isSubmitted) {
          if (isCorrect) {
            backgroundColor = Colors.green.shade100;
          } else if (isSelected) {
            backgroundColor = Colors.red.shade100;
          }
        } else if (isSelected) {
          backgroundColor = Colors.blue.shade100;
        }

        return Card(
          elevation: isSelected ? 4 : 1,
          color: backgroundColor ?? Colors.grey.shade50,
          child: InkWell(
            onTap: () => controller.selectAnswer(letter),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isSelected ? Colors.blue : Colors.grey.shade400,
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: MathText(
                        option,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (isSubmitted && isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (isSubmitted && isSelected && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            ),
          ),
        );
      });
    });
  }

  /// 构建答案输入框（填空题/解答题）
  Widget _buildAnswerInput() {
    return TextField(
      decoration: const InputDecoration(
        labelText: '请输入答案',
        border: OutlineInputBorder(),
      ),
      onChanged: controller.selectAnswer,
      enabled: !controller.isSubmitted.value,
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Obx(() {
      final isSubmitted = controller.isSubmitted.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 上一题
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.currentIndex.value > 0
                    ? controller.previousQuestion
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('上一题'),
              ),
            ),
            const SizedBox(width: 12),

            // 提交/下一题
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isSubmitted
                    ? controller.nextQuestion
                    : controller.submitAnswer,
                icon: Icon(isSubmitted ? Icons.arrow_forward : Icons.check),
                label: Text(isSubmitted ? '下一题' : '提交答案'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'L1':
        return Colors.green.shade200;
      case 'L2':
        return Colors.orange.shade200;
      case 'L3':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}
