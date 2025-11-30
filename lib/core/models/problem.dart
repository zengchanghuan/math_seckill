class Problem {
  final String id;
  final String topic;
  final String difficulty;
  final String question; // LaTeX string
  final String answer;
  final String solution; // LaTeX string
  final List<String> tags;

  Problem({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.solution,
    this.tags = const [],
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      solution: json['solution'] as String,
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
      'tags': tags,
    };
  }
}

