import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// 学生画像页面
class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习画像'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile.value;

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '暂无学习数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '开始刷题后，系统将为您生成详细的学习画像',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 预测分数卡片
              _buildPredictedScoreCard(profile.predictedScore),
              const SizedBox(height: 16),

              // 整体统计卡片
              _buildOverallStatsCard(profile),
              const SizedBox(height: 16),

              // 难度正确率
              _buildDifficultyAccuracyCard(profile),
              const SizedBox(height: 16),

              // 知识点掌握度
              _buildKnowledgeMasteryCard(profile),
              const SizedBox(height: 16),

              // 薄弱知识点
              _buildWeakPointsCard(profile),
              const SizedBox(height: 16),

              // 题型正确率
              _buildQuestionTypeCard(profile),
            ],
          ),
        );
      }),
    );
  }

  /// 构建预测分数卡片
  Widget _buildPredictedScoreCard(double score) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '预测考试分数',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Text(
              '/ 100',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getScoreLevel(score),
              style: TextStyle(
                fontSize: 16,
                color: _getScoreLevelColor(score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建整体统计卡片
  Widget _buildOverallStatsCard(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '整体统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '答题总数',
                  profile.totalAttempts.toString(),
                  Icons.quiz,
                  Colors.blue,
                ),
                _buildStatItem(
                  '正确数',
                  profile.correctCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  '正确率',
                  '${(profile.overallAccuracy * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建难度正确率卡片
  Widget _buildDifficultyAccuracyCard(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '各难度正确率',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'L1 基础题',
              profile.difficultyAccuracy['L1'] ?? 0.0,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              'L2 提升题',
              profile.difficultyAccuracy['L2'] ?? 0.0,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              'L3 挑战题',
              profile.difficultyAccuracy['L3'] ?? 0.0,
              Colors.red,
            ),
            if (profile.needsBasicTraining)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '建议加强基础知识训练',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建知识点掌握度卡片
  Widget _buildKnowledgeMasteryCard(profile) {
    if (profile.knowledgeMastery.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无知识点数据'),
        ),
      );
    }

    final knowledgeList = <MapEntry<String, double>>[];
    profile.knowledgeMastery.forEach((key, value) {
      knowledgeList.add(MapEntry(key, value as double));
    });
    knowledgeList.sort((a, b) => (b.value).compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '知识点掌握度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '最强：${profile.strongestKnowledgePoint}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...knowledgeList.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildProgressBar(
                  entry.key,
                  entry.value,
                  _getMasteryColor(entry.value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建薄弱知识点卡片
  Widget _buildWeakPointsCard(profile) {
    if (profile.weakPoints.isEmpty) {
      return const SizedBox();
    }

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '需要加强的知识点',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.weakPoints.map<Widget>((kp) {
                return Chip(
                  label: Text(kp),
                  backgroundColor: Colors.red.shade100,
                  avatar: const Icon(Icons.error_outline, size: 18, color: Colors.red),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建题型正确率卡片
  Widget _buildQuestionTypeCard(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '题型正确率',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...profile.questionTypeAccuracy.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildProgressBar(
                  _getQuestionTypeName(entry.key),
                  entry.value,
                  Colors.purple,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(String label, double value, Color color) {
    final percent = (value * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  /// 获取分数等级
  String _getScoreLevel(double score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '需努力';
  }

  /// 获取分数等级颜色
  Color _getScoreLevelColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  /// 获取掌握度颜色
  Color _getMasteryColor(double mastery) {
    if (mastery >= 0.8) return Colors.green;
    if (mastery >= 0.6) return Colors.blue;
    if (mastery >= 0.4) return Colors.orange;
    return Colors.red;
  }

  /// 获取题型名称
  String _getQuestionTypeName(String type) {
    switch (type) {
      case 'choice':
        return '选择题';
      case 'fill':
        return '填空题';
      case 'solution':
        return '解答题';
      default:
        return type;
    }
  }
}

