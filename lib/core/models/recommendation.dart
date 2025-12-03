import 'question.dart';

/// 推荐模式枚举
enum RecommendationMode {
  weakPoints('weak_points', '薄弱知识点模式'),
  comprehensive('comprehensive', '综合训练模式'),
  examPrep('exam_prep', '考前冲刺模式');

  final String value;
  final String displayName;

  const RecommendationMode(this.value, this.displayName);

  static RecommendationMode fromString(String value) {
    return RecommendationMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => RecommendationMode.weakPoints,
    );
  }
}

/// 推荐请求模型
class RecommendationRequest {
  final String studentId;
  final RecommendationMode mode;
  final int count;

  RecommendationRequest({
    required this.studentId,
    required this.mode,
    this.count = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'mode': mode.value,
      'count': count,
    };
  }
}

/// 推荐响应模型
class RecommendationResponse {
  final List<QuestionRecommendation> recommendations;
  final String reason; // 推荐理由

  RecommendationResponse({
    required this.recommendations,
    required this.reason,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      recommendations: (json['recommendations'] as List)
          .map((item) => QuestionRecommendation.fromJson(item as Map<String, dynamic>))
          .toList(),
      reason: json['reason'] as String,
    );
  }
}

/// 单个题目推荐
class QuestionRecommendation {
  final Question question;
  final String reason; // 推荐原因
  final double relevanceScore; // 相关度分数

  QuestionRecommendation({
    required this.question,
    required this.reason,
    this.relevanceScore = 1.0,
  });

  factory QuestionRecommendation.fromJson(Map<String, dynamic> json) {
    return QuestionRecommendation(
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      reason: json['reason'] as String? ?? '',
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

