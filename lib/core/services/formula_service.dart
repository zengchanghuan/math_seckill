import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/formula.dart';

class FormulaService extends GetxService {
  List<Formula> _allFormulas = [];
  final RxBool isLoading = false.obs; // 初始为false，等待触发加载
  bool _isLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // 不在启动时加载，改为按需加载
  }

  Future<void> loadFormulas() async {
    if (_isLoaded) return; // 避免重复加载

    try {
      isLoading.value = true;
      print('📐 开始加载公式库...');
      final stopwatch = Stopwatch()..start();

      final String jsonString =
          await rootBundle.loadString('assets/data/formulas.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _allFormulas = jsonData.map((json) => Formula.fromJson(json)).toList();

      stopwatch.stop();
      print(
          '✅ 公式库加载完成：${_allFormulas.length}条公式，耗时${stopwatch.elapsedMilliseconds}ms');
      _isLoaded = true;
    } catch (e) {
      print('❌ 加载公式库失败: $e');
      _allFormulas = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 确保公式库已加载
  Future<void> ensureLoaded() async {
    if (!_isLoaded && !isLoading.value) {
      await loadFormulas();
    }
    // 等待加载完成
    while (isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  List<Formula> getAllFormulas() {
    return List.unmodifiable(_allFormulas);
  }

  List<Formula> getFormulasByCategory(String category) {
    return _allFormulas.where((f) => f.category == category).toList();
  }

  List<Formula> searchFormulas(String query) {
    if (query.isEmpty) return getAllFormulas();
    final lowerQuery = query.toLowerCase();
    return _allFormulas
        .where((f) =>
            f.name.toLowerCase().contains(lowerQuery) ||
            f.description.toLowerCase().contains(lowerQuery) ||
            f.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<String> getAllCategories() {
    return _allFormulas.map((f) => f.category).toSet().toList()..sort();
  }

  Formula? getFormulaById(String id) {
    try {
      return _allFormulas.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}
