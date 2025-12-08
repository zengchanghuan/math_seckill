/// 题目统计模型 - 对应后端 v2.0 QuestionStats
class QuestionStats {
  final String questionId;
  final int totalAttempts;
  final int correctCount;
  final double correctRate;
  final double discriminationIndex;
  final double avgTimeSeconds;
  final Map<String, int> optionDistribution; // 选项分布
  final String qualityStatus; // "excellent", "good", "needs_improvement"

  QuestionStats({
    required this.questionId,
    required this.totalAttempts,
    required this.correctCount,
    required this.correctRate,
    required this.discriminationIndex,
    required this.avgTimeSeconds,
    required this.optionDistribution,
    required this.qualityStatus,
  });

  factory QuestionStats.fromJson(Map<String, dynamic> json) {
    return QuestionStats(
      questionId: json['questionId'] as String,
      totalAttempts: json['totalAttempts'] as int,
      correctCount: json['correctCount'] as int,
      correctRate: (json['correctRate'] as num).toDouble(),
      discriminationIndex: (json['discriminationIndex'] as num).toDouble(),
      avgTimeSeconds: (json['avgTimeSeconds'] as num).toDouble(),
      optionDistribution:
          Map<String, int>.from(json['optionDistribution'] as Map),
      qualityStatus: json['qualityStatus'] as String,
    );
  }

  /// 判断题目是否优质
  bool get isExcellent => qualityStatus == 'excellent';

  /// 判断题目是否需要优化
  bool get needsImprovement => qualityStatus == 'needs_improvement';

  /// 获取正确率的文字描述
  String get correctRateDescription {
    if (correctRate >= 0.8) return '容易';
    if (correctRate >= 0.5) return '适中';
    if (correctRate >= 0.3) return '较难';
    return '很难';
  }

  /// 获取区分度的文字描述
  String get discriminationDescription {
    if (discriminationIndex >= 0.6) return '优秀';
    if (discriminationIndex >= 0.4) return '良好';
    if (discriminationIndex >= 0.3) return '合格';
    return '需改进';
  }
}

/// 题库统计模型
class QuestionBankStats {
  final int totalQuestions;
  final int approvedQuestions;
  final int pendingQuestions;
  final Map<String, int> byDifficulty;
  final Map<String, int> byTopic;
  final Map<String, int> byType;
  final Map<String, int> byReviewStatus;
  final double avgCorrectRate;
  final double avgDiscrimination;

  QuestionBankStats({
    required this.totalQuestions,
    required this.approvedQuestions,
    required this.pendingQuestions,
    required this.byDifficulty,
    required this.byTopic,
    required this.byType,
    required this.byReviewStatus,
    required this.avgCorrectRate,
    required this.avgDiscrimination,
  });

  factory QuestionBankStats.fromJson(Map<String, dynamic> json) {
    return QuestionBankStats(
      totalQuestions: json['totalQuestions'] as int,
      approvedQuestions: json['approvedQuestions'] as int,
      pendingQuestions: json['pendingQuestions'] as int,
      byDifficulty: Map<String, int>.from(json['byDifficulty'] as Map),
      byTopic: Map<String, int>.from(json['byTopic'] as Map),
      byType: Map<String, int>.from(json['byType'] as Map),
      byReviewStatus: Map<String, int>.from(json['byReviewStatus'] as Map),
      avgCorrectRate: (json['avgCorrectRate'] as num).toDouble(),
      avgDiscrimination: (json['avgDiscrimination'] as num).toDouble(),
    );
  }
}





