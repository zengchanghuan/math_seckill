import 'package:get/get.dart';
import '../../../core/models/question.dart';
import '../../../core/models/recommendation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

/// 个性化推荐控制器 - 管理题目推荐
class RecommendController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // 推荐的题目列表
  final RxList<QuestionRecommendation> recommendations = <QuestionRecommendation>[].obs;

  // 推荐理由
  final RxString recommendReason = ''.obs;

  // 当前推荐模式
  final Rx<RecommendationMode> currentMode = RecommendationMode.weakPoints.obs;

  // 加载状态
  final RxBool isLoading = false.obs;

  // 当前学生ID
  String get studentId => _storageService.getStudentId() ?? _apiService.currentStudentId.value;

  @override
  void onInit() {
    super.onInit();
    // 加载默认推荐模式
    final savedMode = _storageService.getDefaultRecommendMode();
    currentMode.value = RecommendationMode.fromString(savedMode);
  }

  /// 获取推荐题目
  Future<void> getRecommendations({
    RecommendationMode? mode,
    int count = 20,
  }) async {
    try {
      isLoading.value = true;

      final recommendMode = mode ?? currentMode.value;

      final request = RecommendationRequest(
        studentId: studentId,
        mode: recommendMode,
        count: count,
      );

      final response = await _apiService.getRecommendations(request);

      if (response != null) {
        recommendations.value = response.recommendations;
        recommendReason.value = response.reason;
        currentMode.value = recommendMode;

        Get.snackbar(
          '推荐成功',
          '已为您推荐 ${recommendations.length} 道题目',
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar('提示', '暂无推荐数据，请先完成一些题目');
      }

    } catch (e) {
      print('Error getting recommendations: $e');
      // Get.snackbar('错误', '获取推荐失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换推荐模式
  Future<void> changeMode(RecommendationMode mode) async {
    if (mode == currentMode.value) return;

    // 保存用户选择
    await _storageService.setDefaultRecommendMode(mode.value);

    // 重新获取推荐
    await getRecommendations(mode: mode);
  }

  /// 获取推荐的题目列表（仅Question对象）
  List<Question> getQuestions() {
    return recommendations.map((rec) => rec.question).toList();
  }

  /// 根据索引获取题目
  Question? getQuestionAt(int index) {
    if (index >= 0 && index < recommendations.length) {
      return recommendations[index].question;
    }
    return null;
  }

  /// 根据索引获取推荐理由
  String getReasonAt(int index) {
    if (index >= 0 && index < recommendations.length) {
      return recommendations[index].reason;
    }
    return '';
  }

  /// 刷新推荐
  Future<void> refresh() async {
    await getRecommendations(mode: currentMode.value);
  }
}

