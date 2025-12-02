import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../../core/models/problem.dart';
import '../../../core/models/user_stats.dart';
import '../../../core/services/problem_service.dart';
import '../../../core/services/remote_problem_service.dart';

class DrillController extends GetxController {
  final ProblemService _problemService = Get.find<ProblemService>();
  final RemoteProblemService _remoteService = RemoteProblemService();

  final RxList<Problem> currentProblems = <Problem>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxString selectedTopic = '全部'.obs;
  final RxString selectedDifficulty = '全部'.obs;
  final RxMap<String, String> userAnswers = <String, String>{}.obs;
  final RxMap<String, bool> answerStatus =
      <String, bool>{}.obs; // true = correct, false = wrong, null = not checked
  final RxMap<String, bool> showSolution = <String, bool>{}.obs;
  final RxList<String> wrongProblemIds = <String>[].obs;

  final Rx<UserStats> userStats = UserStats().obs;

  PageController? pageController;

  @override
  void onInit() {
    super.onInit();
    loadUserStats();
    loadWrongProblems();
    // 延迟过滤题目，等待ProblemService加载完成
    _initProblems();
  }

  Future<void> _initProblems() async {
    // 确保题库已加载（不阻塞，显示加载中状态）
    _problemService.ensureLoaded().then((_) {
      if (!Get.isRegistered<DrillController>()) return;
      filterProblems();
    });
  }

  @override
  void onClose() {
    pageController?.dispose();
    super.onClose();
  }

  void filterProblems() {
    List<Problem> problems;
    if (selectedTopic.value == '全部' && selectedDifficulty.value == '全部') {
      problems = _problemService.getAllProblems();
    } else if (selectedTopic.value == '全部') {
      problems =
          _problemService.getProblemsByDifficulty(selectedDifficulty.value);
    } else if (selectedDifficulty.value == '全部') {
      problems = _problemService.getProblemsByTopic(selectedTopic.value);
    } else {
      problems = _problemService.getProblemsByTopicAndDifficulty(
        selectedTopic.value,
        selectedDifficulty.value,
      );
    }
    currentProblems.value = problems;
    currentIndex.value = 0;
    userAnswers.clear();
    answerStatus.clear();
    showSolution.clear();
    // 重置 PageController
    pageController?.dispose();
    pageController = PageController(initialPage: 0);
  }

  void setTopic(String topic) {
    selectedTopic.value = topic;
    filterProblems();
  }

  void setDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
    filterProblems();
  }

  void setAnswer(String problemId, String answer) {
    userAnswers[problemId] = answer;
  }

  void selectAnswer(String problemId, String selectedOption) {
    // 保存用户选择的答案
    userAnswers[problemId] = selectedOption;

    // 检查答案
    final problem = currentProblems.firstWhere((p) => p.id == problemId);
    final correctAnswer = problem.answer.trim().toUpperCase();
    final isCorrect = selectedOption.toUpperCase() == correctAnswer;

    // 更新答案状态
    answerStatus[problemId] = isCorrect;

    // 更新统计和错题本
    if (!isCorrect) {
      if (!wrongProblemIds.contains(problemId)) {
        wrongProblemIds.add(problemId);
        saveWrongProblems();
      }
    }
    updateUserStats(isCorrect, problem.topic);

    // 如果答案正确，延迟后自动滑动到下一题
    if (isCorrect && pageController != null) {
      Timer(const Duration(milliseconds: 800), () {
        if (currentIndex.value < currentProblems.length - 1) {
          currentIndex.value++;
          pageController!.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void checkAnswer(String problemId) {
    final problem = currentProblems.firstWhere((p) => p.id == problemId);
    final userAnswer = userAnswers[problemId]?.trim() ?? '';
    final correctAnswer = problem.answer.trim();

    final isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
    answerStatus[problemId] = isCorrect;

    if (!isCorrect) {
      if (!wrongProblemIds.contains(problemId)) {
        wrongProblemIds.add(problemId);
        saveWrongProblems();
      }
    }

    updateUserStats(isCorrect, problem.topic);
  }

  /// 检查填空题答案（调用后端判分）
  Future<void> checkFillAnswer(String problemId) async {
    final problem = currentProblems.firstWhere((p) => p.id == problemId);
    final userAnswer = userAnswers[problemId]?.trim() ?? '';

    if (userAnswer.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入答案',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // 调用后端判分接口
      final result = await _remoteService.gradeAnswer(
        problemId: problemId,
        userAnswer: userAnswer,
        problemType: 'fill',
        correctAnswer: problem.answer,
        answerType: problem.answerType,
        correctAnswerExpr: problem.answerExpr,
      );

      final isCorrect = result['isCorrect'] as bool;
      answerStatus[problemId] = isCorrect;

      if (!isCorrect) {
        if (!wrongProblemIds.contains(problemId)) {
          wrongProblemIds.add(problemId);
          saveWrongProblems();
        }
      }

      updateUserStats(isCorrect, problem.topic);

      // 如果答案正确，延迟后自动滑动到下一题
      if (isCorrect && pageController != null) {
        Timer(const Duration(milliseconds: 1500), () {
          if (currentIndex.value < currentProblems.length - 1) {
            currentIndex.value++;
            pageController!.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '判分失败：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  /// 检查解答题答案（调用后端判分）
  Future<void> checkSolutionAnswer(String problemId) async {
    final problem = currentProblems.firstWhere((p) => p.id == problemId);
    final userAnswer = userAnswers[problemId]?.trim() ?? '';

    if (userAnswer.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入最终答案',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // 调用后端判分接口
      final result = await _remoteService.gradeAnswer(
        problemId: problemId,
        userAnswer: userAnswer,
        problemType: 'solution',
        correctAnswer: problem.answer,
        answerType: problem.answerType,
        correctAnswerExpr: problem.answerExpr,
      );

      final isCorrect = result['isCorrect'] as bool;
      answerStatus[problemId] = isCorrect;

      if (!isCorrect) {
        if (!wrongProblemIds.contains(problemId)) {
          wrongProblemIds.add(problemId);
          saveWrongProblems();
        }
      }

      updateUserStats(isCorrect, problem.topic);

      // 如果答案正确，延迟后自动滑动到下一题
      if (isCorrect && pageController != null) {
        Timer(const Duration(milliseconds: 1500), () {
          if (currentIndex.value < currentProblems.length - 1) {
            currentIndex.value++;
            pageController!.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '判分失败：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void toggleSolution(String problemId) {
    showSolution[problemId] = !(showSolution[problemId] ?? false);
  }

  void nextProblem() {
    if (currentIndex.value < currentProblems.length - 1) {
      currentIndex.value++;
    }
  }

  void previousProblem() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  void updateUserStats(bool isCorrect, String topic) {
    userStats.value.totalProblems++;
    if (isCorrect) {
      userStats.value.correctCount++;
    } else {
      userStats.value.wrongCount++;
    }

    if (!userStats.value.topicStats.containsKey(topic)) {
      userStats.value.topicStats[topic] = TopicStats();
    }
    userStats.value.topicStats[topic]!.total++;
    if (isCorrect) {
      userStats.value.topicStats[topic]!.correct++;
    }

    saveUserStats();
  }

  Future<void> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('user_stats');
      if (statsJson != null) {
        userStats.value = UserStats.fromJson(json.decode(statsJson));
      }
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<void> saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'user_stats', json.encode(userStats.value.toJson()));
    } catch (e) {
      print('Error saving user stats: $e');
    }
  }

  Future<void> loadWrongProblems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wrongIds = prefs.getStringList('wrong_problems') ?? [];
      wrongProblemIds.value = wrongIds;
    } catch (e) {
      print('Error loading wrong problems: $e');
    }
  }

  Future<void> saveWrongProblems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('wrong_problems', wrongProblemIds.toList());
    } catch (e) {
      print('Error saving wrong problems: $e');
    }
  }

  int get progress => answerStatus.length;

  int get totalProblems => currentProblems.length;
}
