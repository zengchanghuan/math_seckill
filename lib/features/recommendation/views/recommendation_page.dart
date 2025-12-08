import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recommend_controller.dart';
import '../../../core/models/recommendation.dart';
import '../../../widgets/math_text.dart';

/// 个性化推荐页面
class RecommendationPage extends GetView<RecommendController> {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能推荐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // 推荐模式选择
          _buildModeSelector(),
          const Divider(height: 1),

          // 推荐理由
          Obx(() {
            if (controller.recommendReason.value.isEmpty) {
              return const SizedBox();
            }
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.recommendReason.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),

          // 推荐题目列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.recommendations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无推荐题目',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '请先完成一些题目，系统将根据您的学习情况\n为您推荐最适合的题目',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.getRecommendations(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('获取推荐'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = controller.recommendations[index];
                  return _buildQuestionCard(recommendation, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建推荐模式选择器
  Widget _buildModeSelector() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('推荐模式：', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<RecommendationMode>(
                  segments: RecommendationMode.values.map((mode) {
                    return ButtonSegment<RecommendationMode>(
                      value: mode,
                      label: Text(
                        mode.displayName.replaceAll('模式', ''),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  selected: {controller.currentMode.value},
                  onSelectionChanged: (Set<RecommendationMode> selected) {
                    controller.changeMode(selected.first);
                  },
                ),
              ),
            ],
          ),
        ));
  }

  /// 构建题目卡片
  Widget _buildQuestionCard(QuestionRecommendation recommendation, int index) {
    final question = recommendation.question;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: 跳转到题目详情或开始答题
          Get.snackbar('提示', '题目 ${question.questionId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 题目标题栏
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(question.difficulty),
                              backgroundColor:
                                  _getDifficultyColor(question.difficulty),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              question.topic,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (recommendation.reason.isNotEmpty)
                          Text(
                            '推荐理由：${recommendation.reason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),

              // 题目内容预览
              MathText(
                question.question.length > 100
                    ? '${question.question.substring(0, 100)}...'
                    : question.question,
                textStyle: const TextStyle(fontSize: 16),
              ),

              // 知识点标签
              if (question.knowledgePoints.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    children: question.knowledgePoints.map((kp) {
                      return Chip(
                        label: Text(kp, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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





