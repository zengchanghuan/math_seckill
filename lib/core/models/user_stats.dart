class UserStats {
  int totalProblems;
  int correctCount;
  int wrongCount;
  Map<String, TopicStats> topicStats;

  UserStats({
    this.totalProblems = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    Map<String, TopicStats>? topicStats,
  }) : topicStats = topicStats ?? {};

  double get accuracy {
    if (totalProblems == 0) return 0.0;
    return correctCount / totalProblems;
  }

  String get strongestTopic {
    if (topicStats.isEmpty) return '暂无';
    var sorted = topicStats.entries.toList()
      ..sort((a, b) => b.value.accuracy.compareTo(a.value.accuracy));
    return sorted.first.key;
  }

  String get weakestTopic {
    if (topicStats.isEmpty) return '暂无';
    var sorted = topicStats.entries.toList()
      ..sort((a, b) => a.value.accuracy.compareTo(b.value.accuracy));
    return sorted.first.key;
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalProblems: json['totalProblems'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      topicStats: (json['topicStats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
                key, TopicStats.fromJson(value as Map<String, dynamic>)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProblems': totalProblems,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'topicStats':
          topicStats.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class TopicStats {
  int total;
  int correct;

  TopicStats({
    this.total = 0,
    this.correct = 0,
  });

  double get accuracy {
    if (total == 0) return 0.0;
    return correct / total;
  }

  factory TopicStats.fromJson(Map<String, dynamic> json) {
    return TopicStats(
      total: json['total'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'correct': correct,
    };
  }
}






