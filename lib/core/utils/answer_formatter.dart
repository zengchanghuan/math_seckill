/// 答案格式化工具
class AnswerFormatter {
  /// 格式化答案显示
  /// 将浮点数转换为最简形式
  static String format(String answer) {
    // 移除LaTeX包装
    String cleaned = answer.trim().replaceAll('\$', '');

    try {
      // 尝试解析为数字
      double? num = double.tryParse(cleaned);
      if (num != null) {
        // 如果是整数，显示为整数
        if (num == num.toInt()) {
          return num.toInt().toString();
        }
        // 如果是常见的数学值，转换为符号
        return _convertToSymbolic(num) ?? cleaned;
      }
    } catch (e) {
      // 解析失败，返回原值
    }

    return cleaned;
  }

  /// 转换常见数值为符号表达式
  static String? _convertToSymbolic(double value) {
    final Map<double, String> commonValues = {
      0.5: '\\frac{1}{2}',
      0.8660254037844386: '\\frac{\\sqrt{3}}{2}',
      0.7071067811865476: '\\frac{\\sqrt{2}}{2}',
      1.7320508075688772: '\\sqrt{3}',
      1.4142135623730951: '\\sqrt{2}',
      3.141592653589793: '\\pi',
    };

    // 检查是否匹配常见值（使用容差）
    for (var entry in commonValues.entries) {
      if ((value - entry.key).abs() < 1e-6) {
        return entry.value;
      }
    }

    return null;
  }

  /// 规范化用户输入的答案
  static String normalizeInput(String input) {
    return input.trim().replaceAll(' ', '').replaceAll('\$', '').toUpperCase();
  }

  /// 检查两个答案是否等价
  static bool isEquivalent(String answer1, String answer2) {
    // 规范化
    String norm1 = normalizeInput(answer1);
    String norm2 = normalizeInput(answer2);

    // 直接字符串比较
    if (norm1 == norm2) return true;

    // 数值比较
    try {
      double? val1 = double.tryParse(norm1);
      double? val2 = double.tryParse(norm2);

      if (val1 != null && val2 != null) {
        return (val1 - val2).abs() < 1e-10;
      }
    } catch (e) {
      // 忽略
    }

    return false;
  }
}
