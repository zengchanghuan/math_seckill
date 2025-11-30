import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/models/problem.dart';
import '../../../core/models/user_stats.dart';
import '../../../core/services/problem_service.dart';

class DrillController extends GetxController {
  final ProblemService _problemService = Get.find<ProblemService>();

  final RxList<Problem> currentProblems = <Problem>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxString selectedTopic = '全部'.obs;
  final RxString selectedDifficulty = '全部'.obs;
  final RxMap<String, String> userAnswers = <String, String>{}.obs;
  final RxMap<String, bool> answerStatus = <String, bool>{}.obs; // true = correct, false = wrong, null = not checked
  final RxMap<String, bool> showSolution = <String, bool>{}.obs;
  final RxList<String> wrongProblemIds = <String>[].obs;

  final Rx<UserStats> userStats = UserStats().obs;

  @override
  void onInit() {
    super.onInit();
    loadUserStats();
    loadWrongProblems();
    filterProblems();
  }

  void filterProblems() {
    List<Problem> problems;
    if (selectedTopic.value == '全部' && selectedDifficulty.value == '全部') {
      problems = _problemService.getAllProblems();
    } else if (selectedTopic.value == '全部') {
      problems = _problemService.getProblemsByDifficulty(selectedDifficulty.value);
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
      await prefs.setString('user_stats', json.encode(userStats.value.toJson()));
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

