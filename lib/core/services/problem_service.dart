import 'package:get/get.dart';
import '../models/problem.dart';
import 'problem_cache_service.dart';

class ProblemService extends GetxService {
  List<Problem> _allProblems = [];
  final RxBool isLoading = true.obs; // 初始为true
  bool _isLoaded = false;
  final _cacheService = ProblemCacheService();

  @override
  void onInit() {
    super.onInit();
    // 不在启动时加载，改为按需加载
  }

  Future<void> loadProblems() async {
    if (_isLoaded) return; // 避免重复加载
    
    try {
      isLoading.value = true;
      
      // 使用缓存服务加载（性能优化）
      _allProblems = await _cacheService.loadProblems();
      _isLoaded = true;
    } catch (e) {
      print('❌ 加载题库失败: $e');
      _allProblems = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 清除缓存（题库更新后使用）
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    _isLoaded = false;
    await loadProblems();
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






