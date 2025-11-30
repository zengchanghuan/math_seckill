/// LaTeX 字符串处理工具类
class LatexHelper {
  /// 清理 LaTeX 字符串，移除 $ 分隔符
  /// flutter_math_fork 不需要 $ 符号作为数学模式分隔符
  static String cleanLatex(String latex) {
    // 移除 $ 符号（用于数学模式分隔符）
    String cleaned = latex.replaceAll(RegExp(r'\$'), '');

    // 移除换行符标记（\n 在 JSON 中可能是 \\n）
    cleaned = cleaned.replaceAll(r'\n', ' ');

    return cleaned.trim();
  }

  /// 检查字符串是否包含 LaTeX 数学表达式
  static bool containsMath(String text) {
    return text.contains(RegExp(r'[\\$]|\\[a-zA-Z]+|\\[^a-zA-Z]'));
  }
}

