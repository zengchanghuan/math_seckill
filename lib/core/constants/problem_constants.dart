/// 题型和难度常量定义

/// 题型枚举
enum ProblemType {
  choice('choice', '选择题'),
  fill('fill', '填空题'),
  solution('solution', '解答题');

  const ProblemType(this.value, this.displayName);

  final String value;
  final String displayName;

  static ProblemType fromString(String value) {
    switch (value) {
      case 'choice':
        return ProblemType.choice;
      case 'fill':
        return ProblemType.fill;
      case 'solution':
        return ProblemType.solution;
      default:
        return ProblemType.choice;
    }
  }
}

/// 难度枚举
enum Difficulty {
  l1('L1', '基础题'),
  l2('L2', '提升题'),
  l3('L3', '挑战题');

  const Difficulty(this.value, this.displayName);

  final String value;
  final String displayName;

  static Difficulty fromString(String value) {
    switch (value) {
      case 'L1':
      case '基础': // 兼容旧格式
        return Difficulty.l1;
      case 'L2':
      case '进阶': // 兼容旧格式
        return Difficulty.l2;
      case 'L3':
        return Difficulty.l3;
      default:
        return Difficulty.l1;
    }
  }
}

/// 答案类型枚举
enum AnswerType {
  integer('integer', '整数'),
  floatType('float', '小数'),
  expr('expr', '表达式');

  const AnswerType(this.value, this.displayName);

  final String value;
  final String displayName;

  static AnswerType fromString(String value) {
    switch (value) {
      case 'integer':
        return AnswerType.integer;
      case 'float':
        return AnswerType.floatType;
      case 'expr':
        return AnswerType.expr;
      default:
        return AnswerType.integer;
    }
  }
}

