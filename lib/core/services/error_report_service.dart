import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../models/question.dart';

/// 错误反馈服务
class ErrorReportService {
  static const String _feedbackEmail = '3681577712@qq.com';

  /// 发送题目纠错邮件
  static Future<void> reportQuestionError({
    required Question question,
    required String themeName,
    required String chapterName,
  }) async {
    try {
      // 构建邮件主题
      final subject = '[数学秒杀-题目纠错] ${themeName} - ${chapterName}';

      // 构建邮件正文
      final body = _buildEmailBody(
        question: question,
        themeName: themeName,
        chapterName: chapterName,
      );

      // 创建mailto链接
      final uri = Uri(
        scheme: 'mailto',
        path: _feedbackEmail,
        query: _encodeQueryParameters({
          'subject': subject,
          'body': body,
        }),
      );

      // 尝试打开邮件客户端
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        Get.snackbar(
          '纠错功能',
          '已打开邮件客户端，请发送反馈',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // 如果无法打开邮件客户端，显示错误信息
        Get.snackbar(
          '提示',
          '无法打开邮件客户端\n请手动发送邮件至：$_feedbackEmail',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '无法发送反馈：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 构建邮件正文
  static String _buildEmailBody({
    required Question question,
    required String themeName,
    required String chapterName,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('尊敬的开发者：');
    buffer.writeln();
    buffer.writeln('我在使用数学秒杀APP时发现以下题目存在问题：');
    buffer.writeln();
    buffer.writeln('【题目信息】');
    buffer.writeln('题目ID：${question.questionId}');
    buffer.writeln('所属主题：$themeName');
    buffer.writeln('所属章节：$chapterName');
    buffer.writeln('难度：${question.difficulty}');
    buffer.writeln('题型：${_getQuestionTypeName(question.type)}');
    buffer.writeln();
    buffer.writeln('【题目内容】');
    buffer.writeln(question.question);
    buffer.writeln();

    if (question.options != null && question.options.isNotEmpty) {
      buffer.writeln('【选项】');
      for (int i = 0; i < question.options.length; i++) {
        buffer.writeln('${String.fromCharCode(65 + i)}. ${question.options[i]}');
      }
      buffer.writeln();
    }

    buffer.writeln('【正确答案】');
    buffer.writeln(question.answer);
    buffer.writeln();

    if (question.solution != null && question.solution.isNotEmpty) {
      buffer.writeln('【解析】');
      buffer.writeln(question.solution);
      buffer.writeln();
    }

    buffer.writeln('【问题描述】');
    buffer.writeln('（请在此处描述您发现的问题，如：题目错误、答案错误、解析不清楚等）');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('感谢您的反馈！');

    return buffer.toString();
  }

  /// 获取题型名称
  static String _getQuestionTypeName(String type) {
    switch (type) {
      case 'choice':
        return '选择题';
      case 'fill':
        return '填空题';
      case 'solve':
        return '解答题';
      default:
        return type;
    }
  }

  /// 编码URL查询参数
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

