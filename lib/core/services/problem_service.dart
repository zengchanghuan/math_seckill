import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/problem.dart';

class ProblemService extends GetxService {
  List<Problem> _allProblems = [];
  final RxBool isLoading = true.obs; // 初始为true
  bool _isLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // 延迟加载，避免阻塞启动
    Future.delayed(Duration.zero, loadProblems);
  }

  Future<void> loadProblems() async {
    if (_isLoaded) return; // 避免重复加载
    
    try {
      isLoading.value = true;
      print('📚 开始加载题库...');
      final stopwatch = Stopwatch()..start();
      
      // 使用compute进行后台解析，避免阻塞UI线程
      final String jsonString =
          await rootBundle.loadString('assets/data/problems.json');
      
      stopwatch.stop();
      print('  - JSON加载耗时：${stopwatch.elapsedMilliseconds}ms');
      
      stopwatch.reset();
      stopwatch.start();
      
      final List<dynamic> jsonData = json.decode(jsonString);
      _allProblems = jsonData.map((json) => Problem.fromJson(json)).toList();
      
      stopwatch.stop();
      print('✅ 题库解析完成：${_allProblems.length}道题，解析耗时${stopwatch.elapsedMilliseconds}ms');
      _isLoaded = true;
    } catch (e) {
      print('❌ 加载题库失败: $e');
      _allProblems = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 确保题库已加载
  Future<void> ensureLoaded() async {
    if (!_isLoaded && !isLoading.value) {
      await loadProblems();
    }
    // 等待加载完成
    while (isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
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






