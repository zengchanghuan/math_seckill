import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';
import '../../../core/services/config_service.dart';

/// 刷题侧边栏 - 显示题目列表和导航
class DrillDrawer extends GetView<DrillController> {
  const DrillDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 侧边栏头部
          _buildDrawerHeader(),

          // 主题切换区域
          _buildThemeSelector(),

          // 占位空间（让底部统计固定在底部）
          const Spacer(),

          const Divider(height: 1),

          // 底部统计
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  /// 构建侧边栏头部
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 应用图标和名称
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数学秒杀',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Math Seckill',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 题目统计
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.quiz, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '当前题库：${controller.questions.length} 题',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// 构建主题切换区域
  Widget _buildThemeSelector() {
    final configService = Get.find<ConfigService>();
    final themeConfigs = configService.getAllThemes();

    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主题标题
          Row(
            children: [
              Icon(Icons.category, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '学习主题',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 主题选择列表（使用配置数据）
          ...themeConfigs.map((config) {
            final isSelected = controller.selectedTheme.value == config.name;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  controller.setTheme(config.name);
                  Get.back(); // 切换主题后关闭侧边栏
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.blue.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            config.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              config.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${config.totalQuestions}题 · ${config.chapters.length}章节',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        ],
      ),
    ));
  }

  /// 构建题目列表项
  Widget _buildQuestionTile(int index) {
    return Obx(() {
      final question = controller.questions[index];
      final isCurrent = controller.currentIndex.value == index;

      // 判断题目状态（这里简化处理，实际可以记录每题的答题状态）
      final isAnswered = index < controller.currentIndex.value;

      return ListTile(
        selected: isCurrent,
        selectedTileColor: Colors.blue.shade50,
        leading: CircleAvatar(
          backgroundColor: isCurrent
              ? Colors.blue
              : isAnswered
                  ? Colors.green.shade200
                  : Colors.grey.shade300,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isCurrent || isAnswered ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.topic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(
                question.difficulty,
                style: const TextStyle(fontSize: 11),
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              backgroundColor: _getDifficultyColor(question.difficulty),
            ),
            const SizedBox(width: 4),
            if (isAnswered)
              const Icon(Icons.check, size: 16, color: Colors.green),
          ],
        ),
        trailing: isCurrent
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: () {
          controller.jumpToQuestion(index);
          Get.back(); // 关闭侧边栏
        },
      );
    });
  }

  /// 构建侧边栏底部统计
  Widget _buildDrawerFooter() {
    return Obx(() {
      final chapterConfig = controller.getCurrentChapterConfig();
      final themeConfig = controller.getCurrentThemeConfig();

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            // 章节进度信息
            if (chapterConfig != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '本章节建议',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '题量：${chapterConfig.suggestedQuestions}题 (${chapterConfig.percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      '重要性：${chapterConfig.importance}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapterConfig.focusStrategy,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            // 答题统计
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.quiz,
                    '已答',
                    '${controller.totalAnswered.value}',
                    Colors.blue,
                  ),
                  _buildStatItem(
                    Icons.check_circle,
                    '正确',
                    '${controller.correctCount.value}',
                    Colors.green,
                  ),
                  _buildStatItem(
                    Icons.cancel,
                    '错误',
                    '${controller.wrongCount.value}',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建统计项
  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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

