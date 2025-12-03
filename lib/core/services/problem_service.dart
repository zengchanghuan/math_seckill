import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/question.dart';

/// 题目服务 - 负责从本地加载题目数据（离线模式）
class ProblemService extends GetxService {
  List<Question> _allProblems = [];
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProblems();
  }

  Future<void> loadProblems() async {
    try {
      isLoading.value = true;
      final String jsonString =
          await rootBundle.loadString('assets/data/problems.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _allProblems = jsonData.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      print('Error loading problems: $e');
      _allProblems = [];
    } finally {
      isLoading.value = false;
    }
  }

  List<Question> getAllProblems() {
    return List.unmodifiable(_allProblems);
  }

  List<Question> getProblemsByTopic(String topic) {
    return _allProblems.where((p) => p.topic == topic).toList();
  }

  List<Question> getProblemsByDifficulty(String difficulty) {
    return _allProblems.where((p) => p.difficulty == difficulty).toList();
  }

  List<Question> getProblemsByTopicAndDifficulty(
      String topic, String difficulty) {
    return _allProblems
        .where((p) => p.topic == topic && p.difficulty == difficulty)
        .toList();
  }

  List<String> getAllTopics() {
    return _allProblems.map((p) => p.topic).toSet().toList()..sort();
  }

  List<String> getAllDifficulties() {
    return _allProblems.map((p) => p.difficulty).toSet().toList()..sort();
  }

  Question? getProblemById(String id) {
    try {
      return _allProblems.firstWhere((p) => p.questionId == id);
    } catch (e) {
      return null;
    }
  }
}






