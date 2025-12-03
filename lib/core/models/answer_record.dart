/// 作答记录模型 - 对应后端 v2.0 AnswerRecord schema
class AnswerRecord {
  final String recordId;
  final String studentId;
  final String questionId;
  final String studentAnswer;
  final bool isCorrect;
  final double timeSpentSeconds;
  final DateTime timestamp;

  AnswerRecord({
    required this.recordId,
    required this.studentId,
    required this.questionId,
    required this.studentAnswer,
    required this.isCorrect,
    required this.timeSpentSeconds,
    required this.timestamp,
  });

  factory AnswerRecord.fromJson(Map<String, dynamic> json) {
    return AnswerRecord(
      recordId: json['recordId'] as String,
      studentId: json['studentId'] as String,
      questionId: json['questionId'] as String,
      studentAnswer: json['studentAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeSpentSeconds: (json['timeSpentSeconds'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'studentId': studentId,
      'questionId': questionId,
      'studentAnswer': studentAnswer,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 提交答案请求模型
class SubmitAnswerRequest {
  final String studentId;
  final String questionId;
  final String studentAnswer;
  final double timeSpentSeconds;

  SubmitAnswerRequest({
    required this.studentId,
    required this.questionId,
    required this.studentAnswer,
    required this.timeSpentSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'questionId': questionId,
      'studentAnswer': studentAnswer,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }
}

/// 提交答案响应模型
class SubmitAnswerResponse {
  final bool isCorrect;
  final String correctAnswer;
  final String solution;
  final AnswerRecord record;

  SubmitAnswerResponse({
    required this.isCorrect,
    required this.correctAnswer,
    required this.solution,
    required this.record,
  });

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      isCorrect: json['isCorrect'] as bool,
      correctAnswer: json['correctAnswer'] as String,
      solution: json['solution'] as String,
      record: AnswerRecord.fromJson(json['record'] as Map<String, dynamic>),
    );
  }
}

