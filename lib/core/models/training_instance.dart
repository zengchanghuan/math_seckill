/// 用户训练实例模型

class PaperSection {
  final String sectionName;
  final List<String> questionIds;

  PaperSection({
    required this.sectionName,
    required this.questionIds,
  });

  factory PaperSection.fromJson(Map<String, dynamic> json) {
    return PaperSection(
      sectionName: json['sectionName'] as String,
      questionIds: (json['questionIds'] as List).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'questionIds': questionIds,
    };
  }
}

class TrainingInstance {
  final String instanceId;
  final String? userId;
  final String topic;
  final String difficulty;
  final String? chapter;
  final String? section;
  final List<PaperSection> sections;
  final int totalQuestions;
  final String createdAt;
  final String? completedAt;
  final Map<String, String> userAnswers;
  final Map<String, bool> answerStatus;

  TrainingInstance({
    required this.instanceId,
    this.userId,
    required this.topic,
    required this.difficulty,
    this.chapter,
    this.section,
    required this.sections,
    required this.totalQuestions,
    required this.createdAt,
    this.completedAt,
    Map<String, String>? userAnswers,
    Map<String, bool>? answerStatus,
  })  : userAnswers = userAnswers ?? {},
        answerStatus = answerStatus ?? {};

  factory TrainingInstance.fromJson(Map<String, dynamic> json) {
    // 安全解析userAnswers
    Map<String, String> userAnswers = {};
    if (json['userAnswers'] != null && json['userAnswers'] is Map) {
      (json['userAnswers'] as Map).forEach((key, value) {
        if (key != null && value != null) {
          userAnswers[key.toString()] = value.toString();
        }
      });
    }
    
    // 安全解析answerStatus
    Map<String, bool> answerStatus = {};
    if (json['answerStatus'] != null && json['answerStatus'] is Map) {
      (json['answerStatus'] as Map).forEach((key, value) {
        if (key != null && value != null && value is bool) {
          answerStatus[key.toString()] = value;
        }
      });
    }
    
    return TrainingInstance(
      instanceId: json['instanceId'] as String,
      userId: json['userId'] as String?,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      chapter: json['chapter'] as String?,
      section: json['section'] as String?,
      sections: (json['sections'] as List)
          .map((s) => PaperSection.fromJson(s))
          .toList(),
      totalQuestions: json['totalQuestions'] as int,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      userAnswers: userAnswers,
      answerStatus: answerStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      if (userId != null) 'userId': userId,
      'topic': topic,
      'difficulty': difficulty,
      if (chapter != null) 'chapter': chapter,
      if (section != null) 'section': section,
      'sections': sections.map((s) => s.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'createdAt': createdAt,
      if (completedAt != null) 'completedAt': completedAt,
      'userAnswers': userAnswers,
      'answerStatus': answerStatus,
    };
  }

  /// 获取所有题目ID列表
  List<String> getAllQuestionIds() {
    List<String> ids = [];
    for (var section in sections) {
      ids.addAll(section.questionIds);
    }
    return ids;
  }

  /// 获取已答题数量
  int get answeredCount => userAnswers.length;

  /// 获取正确题数
  int get correctCount =>
      answerStatus.values.where((v) => v == true).length;

  /// 是否已完成
  bool get isCompleted => answeredCount >= totalQuestions;

  /// 完成百分比
  double get completionPercentage =>
      totalQuestions > 0 ? (answeredCount / totalQuestions) : 0.0;
}

