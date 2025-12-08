import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/question.dart';
import './api_service.dart';

/// 错误反馈服务
class ErrorReportService {
  /// 显示纠错对话框
  static Future<void> reportQuestionError({
    required Question question,
    required String themeName,
    required String chapterName,
  }) async {
    final TextEditingController descController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.orange),
            SizedBox(width: 8),
            Text('题目纠错'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '题目：${question.question.substring(0, question.question.length > 30 ? 30 : question.question.length)}...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '问题描述',
                  hintText: '请描述您发现的问题...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final description = descController.text.trim();
              if (description.isEmpty) {
                Get.snackbar('提示', '请填写问题描述');
                return;
              }

              Get.back();
              await _submitFeedback(
                question: question,
                themeName: themeName,
                chapterName: chapterName,
                description: description,
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  /// 提交反馈到后端
  static Future<void> _submitFeedback({
    required Question question,
    required String themeName,
    required String chapterName,
    required String description,
  }) async {
    try {
      final apiService = Get.find<ApiService>();

      await apiService.submitFeedback({
        'questionId': question.questionId,
        'themeName': themeName,
        'chapterName': chapterName,
        'difficulty': question.difficulty,
        'type': question.type,
        'question': question.question,
        'options': question.options,
        'answer': question.answer,
        'solution': question.solution,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        '提交成功',
        '感谢您的反馈！我们会尽快处理',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '提交失败',
        '请稍后重试：$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

}

