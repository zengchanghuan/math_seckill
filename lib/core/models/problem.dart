class Problem {
  final String id;
  final String topic;
  final String difficulty; // "L1", "L2", "L3" 或兼容旧格式 "基础", "进阶"
  final String type; // "choice", "fill", "solution"
  final String question; // LaTeX string
  final String answer; // 选择题: A/B/C/D; 填空题/解答题: 文本答案
  final String solution; // LaTeX string
  final List<String> options; // 选项列表，选择题必填，其他题型为空
  final List<String> tags;
  final String? chapter; // 章节，例如 "第1章 三角函数"
  final String? section; // 节，例如 "§1.1 三角函数的概念"
  final String? answerType; // "integer", "float", "expr"，用于填空题和解答题
  final String? answerExpr; // SymPy表达式字符串，用于判分

  Problem({
    required this.id,
    required this.topic,
    required this.difficulty,
    String? type,
    required this.question,
    required this.answer,
    required this.solution,
    List<String>? options,
    this.tags = const [],
    this.chapter,
    this.section,
    this.answerType,
    this.answerExpr,
  })  : type = type ?? 'choice', // 默认为选择题，保持向后兼容
        options = options ?? [];

  factory Problem.fromJson(Map<String, dynamic> json) {
    List<String> options = [];
    if (json['options'] != null) {
      if (json['options'] is List) {
        options = (json['options'] as List).map((e) => e.toString()).toList();
      }
    }

    // 难度兼容：如果是旧格式，自动转换
    String difficulty = json['difficulty'] as String;
    if (difficulty == '基础') {
      difficulty = 'L1';
    } else if (difficulty == '进阶') {
      difficulty = 'L2';
    }

    return Problem(
      id: (json['id'] ?? json['questionId']) as String, // 兼容后端返回的questionId字段
      topic: json['topic'] as String,
      difficulty: difficulty,
      type: json['type'] as String?, // 如果缺失，构造函数会默认为'choice'
      question: json['question'] as String,
      answer: json['answer'] as String,
      solution: json['solution'] as String,
      options: options,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      chapter: json['chapter'] as String?,
      section: json['section'] as String?,
      answerType: json['answerType'] as String?,
      answerExpr: json['answerExpr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'difficulty': difficulty,
      'type': type,
      'question': question,
      'answer': answer,
      'solution': solution,
      'options': options,
      'tags': tags,
      if (chapter != null) 'chapter': chapter,
      if (section != null) 'section': section,
      if (answerType != null) 'answerType': answerType,
      if (answerExpr != null) 'answerExpr': answerExpr,
    };
  }
}
