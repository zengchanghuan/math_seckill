/// 题目模型 - 对应后端 v2.0 Question schema
class Question {
  final String questionId;
  final String topic;
  final String difficulty; // "L1", "L2", "L3"
  final String type; // "choice", "fill", "solution"
  final String question;
  final String answer;
  final List<String>? options;
  final String solution;
  final List<String> tags;

  // 后端 v2.0 新增字段
  final List<String> knowledgePoints; // 知识点标签
  final List<String> abilityTags; // 能力要求标签 ["memory", "understand", "apply", "analyze", "synthesize", "model"]
  final String? templateId; // 题型模板ID
  final String source; // "generated", "real_exam", "manual"
  final bool isRealExam; // 是否真题

  // 质量统计数据
  final int totalAttempts; // 总作答次数
  final double correctRate; // 正确率
  final double discriminationIndex; // 区分度
  final double avgTimeSeconds; // 平均耗时（秒）

  // 审核状态
  final String reviewStatus; // "pending", "approved", "rejected", "revision"

  // 可选字段
  final String? answerType;
  final String? answerExpr;

  Question({
    required this.questionId,
    required this.topic,
    required this.difficulty,
    required this.type,
    required this.question,
    required this.answer,
    this.options,
    required this.solution,
    required this.tags,
    required this.knowledgePoints,
    required this.abilityTags,
    this.templateId,
    this.source = 'manual',
    this.isRealExam = false,
    this.totalAttempts = 0,
    this.correctRate = 0.0,
    this.discriminationIndex = 0.0,
    this.avgTimeSeconds = 0.0,
    this.reviewStatus = 'pending',
    this.answerType,
    this.answerExpr,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'] as String? ?? json['id'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      solution: json['solution'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      knowledgePoints: json['knowledgePoints'] != null
          ? List<String>.from(json['knowledgePoints'] as List)
          : [],
      abilityTags: json['abilityTags'] != null
          ? List<String>.from(json['abilityTags'] as List)
          : [],
      templateId: json['templateId'] as String?,
      source: json['source'] as String? ?? 'manual',
      isRealExam: json['isRealExam'] as bool? ?? false,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0.0,
      discriminationIndex: (json['discriminationIndex'] as num?)?.toDouble() ?? 0.0,
      avgTimeSeconds: (json['avgTimeSeconds'] as num?)?.toDouble() ?? 0.0,
      reviewStatus: json['reviewStatus'] as String? ?? 'pending',
      answerType: json['answerType'] as String?,
      answerExpr: json['answerExpr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'topic': topic,
      'difficulty': difficulty,
      'type': type,
      'question': question,
      'answer': answer,
      'options': options,
      'solution': solution,
      'tags': tags,
      'knowledgePoints': knowledgePoints,
      'abilityTags': abilityTags,
      'templateId': templateId,
      'source': source,
      'isRealExam': isRealExam,
      'totalAttempts': totalAttempts,
      'correctRate': correctRate,
      'discriminationIndex': discriminationIndex,
      'avgTimeSeconds': avgTimeSeconds,
      'reviewStatus': reviewStatus,
      'answerType': answerType,
      'answerExpr': answerExpr,
    };
  }

  /// 判断题目质量是否优秀（区分度 > 0.6）
  bool get isHighQuality => discriminationIndex > 0.6;

  /// 判断题目是否需要优化（区分度 < 0.3）
  bool get needsImprovement => discriminationIndex < 0.3;

  /// 判断题目是否已审核通过
  bool get isApproved => reviewStatus == 'approved';
}


