import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/problem.dart';

class ProblemService extends GetxService {
  List<Problem> _allProblems = [];
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
      _allProblems = jsonData.map((json) => Problem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading problems: $e');
      _allProblems = [];
    } finally {
      isLoading.value = false;
    }
  }

  List<Problem> getAllProblems() {
    return List.unmodifiable(_allProblems);
  }

  List<Problem> getProblemsByTopic(String topic) {
    return _allProblems.where((p) => p.topic == topic).toList();
  }

  List<Problem> getProblemsByDifficulty(String difficulty) {
    return _allProblems.where((p) => p.difficulty == difficulty).toList();
  }

  List<Problem> getProblemsByTopicAndDifficulty(
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

  Problem? getProblemById(String id) {
    try {
      return _allProblems.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}


