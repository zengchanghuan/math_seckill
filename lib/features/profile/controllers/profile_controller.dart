import 'package:get/get.dart';
import '../../../core/models/student_profile.dart';
import '../../../core/models/answer_record.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

/// 学生画像控制器 - 管理学生学习数据和能力画像
class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // 学生画像
  final Rx<StudentProfile?> profile = Rx<StudentProfile?>(null);

  // 作答记录
  final RxList<AnswerRecord> answerRecords = <AnswerRecord>[].obs;

  // 加载状态
  final RxBool isLoading = false.obs;

  // 当前学生ID
  String get studentId =>
      _storageService.getStudentId() ?? _apiService.currentStudentId.value;

  @override
  void onInit() {
    super.onInit();
    _initLoad();
  }

  /// 初始化加载
  Future<void> _initLoad() async {
    try {
      isLoading.value = true;

      // 添加超时控制
      await Future.wait([
        loadProfile(),
        loadAnswerRecords(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ 加载超时，使用默认数据');
          return [];
        },
      );
    } catch (e) {
      print('❌ 初始化加载失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载学生画像
  Future<void> loadProfile() async {
    try {
      final result = await _apiService.getStudentProfile(studentId).timeout(
            const Duration(seconds: 5),
          );

      if (result != null) {
        profile.value = result;
        print('✅ 学生画像加载成功');
      } else {
        print('ℹ️ 暂无学习画像数据');
      }
    } catch (e) {
      print('⚠️ 加载学生画像失败: $e');
      // 不抛出异常，让应用继续运行
    }
  }

  /// 加载作答记录
  Future<void> loadAnswerRecords() async {
    try {
      final records = await _apiService.getStudentAnswers(studentId).timeout(
            const Duration(seconds: 5),
          );
      answerRecords.value = records;
      print('✅ 作答记录加载成功: ${records.length}条');
    } catch (e) {
      print('⚠️ 加载作答记录失败: $e');
      answerRecords.value = [];
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadProfile(),
        loadAnswerRecords(),
      ]).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('刷新失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取知识点掌握度百分比
  double getKnowledgeMasteryPercent(String knowledgePoint) {
    if (profile.value == null) return 0.0;
    return (profile.value!.knowledgeMastery[knowledgePoint] ?? 0.0) * 100;
  }

  /// 获取难度正确率百分比
  double getDifficultyAccuracyPercent(String difficulty) {
    if (profile.value == null) return 0.0;
    return (profile.value!.difficultyAccuracy[difficulty] ?? 0.0) * 100;
  }

  /// 获取总体正确率百分比
  double get overallAccuracyPercent {
    if (profile.value == null) return 0.0;
    return profile.value!.overallAccuracy * 100;
  }

  /// 获取预测分数
  double get predictedScore {
    return profile.value?.predictedScore ?? 0.0;
  }

  /// 获取最近N条作答记录
  List<AnswerRecord> getRecentRecords(int count) {
    if (answerRecords.length <= count) {
      return answerRecords.toList();
    }
    return answerRecords.sublist(0, count);
  }

  /// 获取错题记录
  List<AnswerRecord> getWrongRecords() {
    return answerRecords.where((record) => !record.isCorrect).toList();
  }

  /// 获取正确题目记录
  List<AnswerRecord> getCorrectRecords() {
    return answerRecords.where((record) => record.isCorrect).toList();
  }
}
