import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/question.dart';
import '../models/answer_record.dart';
import '../models/student_profile.dart';
import '../models/recommendation.dart';
import '../models/question_stats.dart';
import '../models/tutorial.dart';

/// API 服务 - 连接后端 v2.0 接口
class ApiService extends GetxService {
  // 后端服务器地址（Mac热点模式使用192.168.2.1）
  static const String baseUrl = 'http://192.168.2.1:8000';

  // 可配置的服务器地址
  final RxString serverUrl = baseUrl.obs;

  // 当前学生ID（模拟登录）
  final RxString currentStudentId = 'student_001'.obs;

  // API请求头
  Map<String, String> get headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  /// 设置服务器地址
  void setServerUrl(String url) {
    serverUrl.value =
        url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// 设置当前学生ID
  void setStudentId(String studentId) {
    currentStudentId.value = studentId;
  }

  /// 健康检查
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('${serverUrl.value}/'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // ==================== 题库管理 ====================

  /// 获取题库统计
  Future<QuestionBankStats?> getQuestionBankStats() async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/questions/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QuestionBankStats.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting question bank stats: $e');
      return null;
    }
  }

  /// 获取单个题目
  Future<Question?> getQuestion(String questionId) async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/questions/$questionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Question.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting question: $e');
      return null;
    }
  }

  /// 创建题目
  Future<Question?> createQuestion(Question question) async {
    try {
      final response = await http.post(
        Uri.parse('${serverUrl.value}/api/questions'),
        headers: headers,
        body: json.encode(question.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Question.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error creating question: $e');
      return null;
    }
  }

  // ==================== 作答记录 ====================

  /// 提交答案
  Future<SubmitAnswerResponse?> submitAnswer(
      SubmitAnswerRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${serverUrl.value}/api/answers/submit'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return SubmitAnswerResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error submitting answer: $e');
      return null;
    }
  }

  /// 获取学生作答记录
  Future<List<AnswerRecord>> getStudentAnswers(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/answers/student/$studentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        // 后端可能返回Map或List，需要处理两种情况
        if (decoded is List) {
          return decoded
              .map(
                  (item) => AnswerRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map && decoded.containsKey('records')) {
          final List<dynamic> records = decoded['records'] as List;
          return records
              .map(
                  (item) => AnswerRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting student answers: $e');
      return [];
    }
  }

  // ==================== 学生画像 ====================

  /// 获取学生能力画像
  Future<StudentProfile?> getStudentProfile(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/student/$studentId/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return StudentProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting student profile: $e');
      return null;
    }
  }

  // ==================== 个性化推荐 ====================

  /// 获取个性化推荐题目
  Future<RecommendationResponse?> getRecommendations(
      RecommendationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${serverUrl.value}/api/student/recommend'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return RecommendationResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting recommendations: $e');
      return null;
    }
  }

  // ==================== 题目统计 ====================

  /// 获取题目统计信息
  Future<QuestionStats?> getQuestionStats(String questionId) async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/admin/question/$questionId/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QuestionStats.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting question stats: $e');
      return null;
    }
  }

  // ==================== 知识点讲解 ====================

  /// 获取所有讲解内容
  Future<TutorialsResponse?> getAllTutorials() async {
    try {
      final response = await http.get(
        Uri.parse('${serverUrl.value}/api/tutorials'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return TutorialsResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting tutorials: $e');
      return null;
    }
  }

  /// 获取指定章节的讲解内容
  Future<TutorialChapter?> getChapterTutorial(
      String themeName, String chapterName) async {
    try {
      final encodedTheme = Uri.encodeComponent(themeName);
      final encodedChapter = Uri.encodeComponent(chapterName);

      final response = await http.get(
        Uri.parse(
            '${serverUrl.value}/api/tutorials/chapter/$encodedTheme/$encodedChapter'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return TutorialChapter.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting chapter tutorial: $e');
      return null;
    }
  }

  // ==================== 反馈管理 ====================

  /// 提交题目纠错反馈
  Future<void> submitFeedback(Map<String, dynamic> feedback) async {
    try {
      final response = await http.post(
        Uri.parse('${serverUrl.value}/api/feedback'),
        headers: headers,
        body: json.encode(feedback),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }
}
