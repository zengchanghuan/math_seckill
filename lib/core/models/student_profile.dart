/// 学生画像模型 - 对应后端 v2.0 StudentProfile schema
class StudentProfile {
  final String studentId;
  final Map<String, double> knowledgeMastery; // 知识点掌握度
  final Map<String, double> questionTypeAccuracy; // 题型正确率
  final Map<String, double> difficultyAccuracy; // 难度正确率
  final List<String> weakPoints; // 薄弱知识点
  final double predictedScore; // 预测分数
  final int totalAttempts; // 总答题数
  final int correctCount; // 正确数
  final double avgTimePerQuestion; // 平均每题耗时

  StudentProfile({
    required this.studentId,
    required this.knowledgeMastery,
    required this.questionTypeAccuracy,
    required this.difficultyAccuracy,
    required this.weakPoints,
    required this.predictedScore,
    this.totalAttempts = 0,
    this.correctCount = 0,
    this.avgTimePerQuestion = 0.0,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    // 安全地处理可能为null的Map
    Map<String, double> parseDoubleMap(dynamic data) {
      if (data == null) return {};
      final map = data as Map<String, dynamic>;
      return map.map((key, value) {
        if (value == null) return MapEntry(key, 0.0);
        return MapEntry(key, (value as num).toDouble());
      });
    }

    return StudentProfile(
      studentId: json['studentId'] as String,
      knowledgeMastery: parseDoubleMap(json['knowledgeMastery']),
      questionTypeAccuracy: parseDoubleMap(json['questionTypeAccuracy']),
      difficultyAccuracy: parseDoubleMap(json['difficultyAccuracy']),
      weakPoints: json['weakPoints'] != null
          ? List<String>.from(json['weakPoints'] as List)
          : [],
      predictedScore: json['predictedScore'] != null
          ? (json['predictedScore'] as num).toDouble()
          : 0.0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      avgTimePerQuestion: json['avgTimePerQuestion'] != null
          ? (json['avgTimePerQuestion'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'knowledgeMastery': knowledgeMastery,
      'questionTypeAccuracy': questionTypeAccuracy,
      'difficultyAccuracy': difficultyAccuracy,
      'weakPoints': weakPoints,
      'predictedScore': predictedScore,
      'totalAttempts': totalAttempts,
      'correctCount': correctCount,
      'avgTimePerQuestion': avgTimePerQuestion,
    };
  }

  /// 总体正确率
  double get overallAccuracy {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  /// 获取最强知识点
  String get strongestKnowledgePoint {
    if (knowledgeMastery.isEmpty) return '暂无';
    var sorted = knowledgeMastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// 获取最弱知识点
  String get weakestKnowledgePoint {
    if (knowledgeMastery.isEmpty) return '暂无';
    var sorted = knowledgeMastery.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  /// 判断是否需要加强基础（L1正确率 < 0.7）
  bool get needsBasicTraining {
    return (difficultyAccuracy['L1'] ?? 0.0) < 0.7;
  }

  /// 判断是否可以挑战难题（L2正确率 > 0.75）
  bool get readyForChallenge {
    return (difficultyAccuracy['L2'] ?? 0.0) > 0.75;
  }
}

