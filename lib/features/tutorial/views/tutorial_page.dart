import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../drill/controllers/drill_controller.dart';
import '../../drill/widgets/chapter_selector_tabs.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/tutorial.dart';
import '../../../widgets/math_text.dart';
import '../widgets/trig_unit_circle_viz.dart';
import '../widgets/complex_plane_viz.dart';
import '../widgets/parametric_curve_viz.dart';

/// 讲解页面 - 展示当前章节的知识点讲解（记忆卡片）
class TutorialPage extends GetView<DrillController> {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('知识点讲解'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 章节选择器（标签页样式）- 与刷题页面相同
          const ChapterSelectorTabs(),
          const Divider(height: 1),

          // 讲解内容
          Expanded(
            child: Obx(() {
              final themeName = controller.selectedTheme.value;
              final chapterName = controller.selectedChapter.value;

              return FutureBuilder<TutorialChapter?>(
                future: Get.find<ApiService>()
                    .getChapterTutorial(themeName, chapterName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return _buildEmptyState(chapterName);
                  }

                  final chapter = snapshot.data!;
                  return _buildChapterContent(chapter);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建章节内容
  Widget _buildChapterContent(TutorialChapter chapter) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 章节标题
        _buildChapterHeader(chapter.chapterName),
        const SizedBox(height: 16),

        // 动态可视化（根据章节显示）
        _buildVisualization(chapter.chapterName),

        // 按小节展示知识卡片
        ...chapter.sections.map((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(section.sectionName),
              const SizedBox(height: 12),

              // 知识卡片列表
              ...section.knowledgeCards.asMap().entries.map((entry) {
                return _buildKnowledgeCard(entry.value, entry.key);
              }),

              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  /// 构建章节标题
  Widget _buildChapterHeader(String chapterName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.book, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              chapterName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建小节标题
  Widget _buildSectionHeader(String sectionName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            sectionName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建知识卡片（记忆卡片风格）
  Widget _buildKnowledgeCard(KnowledgeCard card, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片序号和标题
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 摘要
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.summary,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 公式
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.functions,
                        color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MathText(
                        card.formula,
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(String chapterName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无「$chapterName」的讲解内容',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '请切换到其他章节查看\n或等待内容更新',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建可视化组件（根据章节内容）
  Widget _buildVisualization(String chapterName) {
    // 根据章节名称显示对应的可视化
    if (chapterName.contains('三角函数')) {
      return const Column(
        children: [
          TrigUnitCircleViz(),
          SizedBox(height: 16),
        ],
      );
    } else if (chapterName.contains('复数')) {
      return const Column(
        children: [
          ComplexPlaneViz(),
          SizedBox(height: 16),
        ],
      );
    } else if (chapterName.contains('参数方程')) {
      return const Column(
        children: [
          ParametricCurveViz(),
          SizedBox(height: 16),
        ],
      );
    }

    // 其他章节不显示可视化
    return const SizedBox();
  }
}
