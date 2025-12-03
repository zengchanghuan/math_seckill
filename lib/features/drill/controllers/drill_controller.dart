import 'package:get/get.dart';
import '../../../core/models/question.dart';
import '../../../core/models/answer_record.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/problem_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/config_service.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/utils/answer_formatter.dart';

/// 刷题控制器 - 管理刷题流程和状态
class DrillController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ProblemService _problemService = Get.find<ProblemService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ConfigService _configService = Get.find<ConfigService>();

  // 当前题目列表
  final RxList<Question> questions = <Question>[].obs;

  // 当前题目索引
  final RxInt currentIndex = 0.obs;

  // 用户答案
  final RxString userAnswer = ''.obs;

  // 是否已提交答案
  final RxBool isSubmitted = false.obs;

  // 是否显示解析
  final RxBool showSolution = false.obs;

  // 是否正确
  final RxBool isCorrect = false.obs;

  // 答题开始时间
  DateTime? _startTime;

  // 统计数据
  final RxInt totalAnswered = 0.obs;
  final RxInt correctCount = 0.obs;
  final RxInt wrongCount = 0.obs;

  // 主题和章节（主题在侧边栏切换，章节在主页面切换）
  final RxString selectedTheme = '高中衔接大学数学基础'.obs;
  final RxString selectedChapter = '第1章 三角函数'.obs; // 默认第一章

  // 加载状态
  final RxBool isLoading = false.obs;

  // 是否离线模式
  bool get isOfflineMode => _storageService.isOfflineMode();

  // 当前题目
  Question? get currentQuestion {
    if (currentIndex.value >= 0 && currentIndex.value < questions.length) {
      return questions[currentIndex.value];
    }
    return null;
  }

  // 正确率
  double get accuracy {
    if (totalAnswered.value == 0) return 0.0;
    return correctCount.value / totalAnswered.value;
  }

  @override
  void onInit() {
    super.onInit();
    // 等待 ProblemService 加载完成后再加载题目
    ever(_problemService.isLoading, (loading) {
      if (!loading && questions.isEmpty) {
        loadQuestions();
      }
    });

    // 如果已经加载完成，直接加载题目
    if (!_problemService.isLoading.value) {
      loadQuestions();
    }
  }

  /// 加载题目
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;

      // 从本地加载题目（离线模式或作为备用）
      final allProblems = _problemService.getAllProblems();

      print('📚 [加载题目] 总题目数：${allProblems.length}');
      print('🎯 [加载题目] 当前主题：${selectedTheme.value}');
      print('📖 [加载题目] 当前章节：${selectedChapter.value}');

      // 如果题目还在加载中，等待
      if (allProblems.isEmpty && _problemService.isLoading.value) {
        print('⏳ [等待] 题目正在加载中...');
        isLoading.value = false;
        return;
      }

      // 应用筛选 - 创建新列表以避免修改不可变列表
      List<Question> filtered = List.from(allProblems);

      // 根据章节筛选（如果选择了具体章节）
      if (selectedChapter.value != '全部') {
        // 提取关键词
        final chapterKeyword = selectedChapter.value.contains('章')
            ? selectedChapter.value.split(' ').last
            : selectedChapter.value;

        print('🔍 [筛选] 章节关键词：$chapterKeyword');

        // 精确匹配
        filtered = filtered.where((q) {
          final topicMatch = q.topic.contains(chapterKeyword);
          final tagsMatch = q.tags.any((tag) => tag.contains(chapterKeyword));
          return topicMatch || tagsMatch;
        }).toList();

        print('✅ [筛选] 精确匹配结果：${filtered.length}题');

        // 如果没有结果，尝试模糊匹配
        if (filtered.isEmpty && chapterKeyword.length > 1) {
          print('⚠️ [筛选] 精确匹配无结果，尝试模糊匹配...');

          // 拆分关键词（例如："极限与连续" -> ["极限", "连续"]）
          final keywords = chapterKeyword
              .split('与')
              .expand((part) => part.split('和'))
              .where((k) => k.isNotEmpty)
              .toList();

          filtered = allProblems.where((q) {
            for (final kw in keywords) {
              if (q.topic.contains(kw) ||
                  q.tags.any((tag) => tag.contains(kw))) {
                return true;
              }
            }
            return false;
          }).toList();

          print('✅ [筛选] 模糊匹配结果：${filtered.length}题');
        }
      } else {
        print('📋 [筛选] 加载全部章节题目');
      }

      // 打乱顺序
      filtered.shuffle();

      questions.value = filtered;
      currentIndex.value = 0;

      // 重置答题状态
      if (filtered.isNotEmpty) {
        startQuestion();
      }

      // 提示信息
      if (filtered.isEmpty) {
        print('❌ [结果] 当前筛选条件下没有题目');
        Get.snackbar(
          '提示',
          '当前章节「${selectedChapter.value}」暂无题目\n\n可能原因：\n1. 题目数据暂未添加\n2. 请选择其他章节',
          duration: const Duration(seconds: 3),
        );
      } else {
        print('🎉 [结果] 成功加载 ${filtered.length} 道题目');
      }
    } catch (e) {
      print('❌ [错误] 加载题目失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换学习主题（从侧边栏调用）
  void setTheme(String theme) {
    selectedTheme.value = theme;

    // 自动选择第一章
    final chapters = getChaptersForCurrentTheme();
    if (chapters.isNotEmpty) {
      selectedChapter.value = chapters.first;
    }

    loadQuestions();
  }

  /// 切换章节（从主页面调用）
  void setChapter(String chapter) {
    selectedChapter.value = chapter;
    loadQuestions();
  }

  /// 获取当前主题的章节列表（不包含"全部"选项）
  List<String> getChaptersForCurrentTheme() {
    // 优先从 ConfigService 获取（服务器配置）
    final config = _configService.getThemeConfig(selectedTheme.value);
    if (config == null) return [];

    return config.chapters.map((c) => c.chapterName).toList();
  }

  /// 获取当前主题的配置
  ThemeConfig? getCurrentThemeConfig() {
    return _configService.getThemeConfig(selectedTheme.value);
  }

  /// 获取当前章节的配置
  ChapterConfig? getCurrentChapterConfig() {
    final config = getCurrentThemeConfig();
    if (config == null || selectedChapter.value == '全部') return null;

    try {
      return config.chapters.firstWhere(
        (c) => c.chapterName == selectedChapter.value,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取当前章节的建议题量
  String getChapterInfo() {
    final chapterConfig = getCurrentChapterConfig();
    if (chapterConfig == null) {
      return '全部章节';
    }

    return '${chapterConfig.chapterName} · '
        '建议${chapterConfig.suggestedQuestions}题 · '
        '重要性：${chapterConfig.importance}';
  }

  /// 开始答题
  void startQuestion() {
    _startTime = DateTime.now();
    userAnswer.value = '';
    isSubmitted.value = false;
    showSolution.value = false;
    isCorrect.value = false;
  }

  /// 选择答案（选择后自动提交）
  void selectAnswer(String answer) {
    if (!isSubmitted.value) {
      userAnswer.value = answer;
      // 自动提交答案
      Future.delayed(const Duration(milliseconds: 300), () {
        submitAnswer();
      });
    }
  }

  /// 提交答案
  Future<void> submitAnswer() async {
    if (userAnswer.value.isEmpty || currentQuestion == null) {
      Get.snackbar('提示', '请先选择答案');
      return;
    }

    if (isSubmitted.value) {
      return;
    }

    try {
      isLoading.value = true;

      // 计算耗时
      final timeSpent = _startTime != null
          ? DateTime.now().difference(_startTime!).inSeconds.toDouble()
          : 0.0;

      final question = currentQuestion!;

      // 检查答案是否正确（使用智能比对）
      final correct = AnswerFormatter.isEquivalent(
        userAnswer.value,
        question.answer,
      );
      isCorrect.value = correct;
      isSubmitted.value = true;

      // 更新统计
      totalAnswered.value++;
      if (correct) {
        correctCount.value++;
      } else {
        wrongCount.value++;
      }

      // 如果不是离线模式，提交到后端
      if (!isOfflineMode) {
        final studentId = _storageService.getStudentId() ??
            _apiService.currentStudentId.value;

        final request = SubmitAnswerRequest(
          studentId: studentId,
          questionId: question.questionId,
          studentAnswer: userAnswer.value,
          timeSpentSeconds: timeSpent,
        );

        final response = await _apiService.submitAnswer(request);

        if (response != null) {
          print('Answer submitted successfully');
        } else {
          print('Failed to submit answer to server');
        }
      }

      // 如果答对，自动下一题；如果答错，显示解析
      if (correct) {
        // 答对了，延迟1.5秒后自动跳转下一题
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (isSubmitted.value) {
            nextQuestion();
          }
        });
      } else {
        // 答错了，自动显示解析
        if (_storageService.isShowSolution()) {
          showSolution.value = true;
        }
      }
    } catch (e) {
      print('Error submitting answer: $e');
      Get.snackbar('错误', '提交答案失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 下一题
  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      startQuestion();
    } else {
      // 已完成所有题目
      Get.snackbar(
        '完成',
        '恭喜！已完成所有题目\n正确率：${(accuracy * 100).toStringAsFixed(1)}%',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 上一题
  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      startQuestion();
    }
  }

  /// 跳转到指定题目
  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentIndex.value = index;
      startQuestion();
    }
  }

  /// 重置统计
  void resetStats() {
    totalAnswered.value = 0;
    correctCount.value = 0;
    wrongCount.value = 0;
  }

  /// 切换解析显示
  void toggleSolution() {
    showSolution.value = !showSolution.value;
  }
}
