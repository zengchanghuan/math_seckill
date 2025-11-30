class Problem {
  final String id;
  final String topic;
  final String difficulty;
  final String question; // LaTeX string
  final String answer; // A, B, C, or D
  final String solution; // LaTeX string
  final List<String> options; // 选项列表，格式: ["选项A内容", "选项B内容", "选项C内容", "选项D内容"]
  final List<String> tags;

  Problem({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.solution,
    List<String>? options,
    this.tags = const [],
  }) : options = options ?? [];

  factory Problem.fromJson(Map<String, dynamic> json) {
    List<String> options = [];
    if (json['options'] != null) {
      if (json['options'] is List) {
        options = (json['options'] as List).map((e) => e.toString()).toList();
      }
    }

    return Problem(
      id: json['id'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      solution: json['solution'] as String,
      options: options,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'difficulty': difficulty,
      'question': question,
      'answer': answer,
      'solution': solution,
      'options': options,
      'tags': tags,
    };
  }
}

