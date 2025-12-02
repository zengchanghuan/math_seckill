import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/problem.dart';

/// 题库服务V2（分片加载版本）
class ProblemServiceV2 extends GetxService {
  static const String _cacheBoxName = 'problems_cache_v2';
  static const String _cacheVersion = '2.0';

  final Map<String, List<Problem>> _problemsByTopic = {};
  final RxBool isLoading = false.obs;
  final RxString loadingTopic = ''.obs;
  final RxSet<String> loadedTopics = <String>{}.obs;

  Box? _cacheBox;
  Map<String, dynamic> _index = {};

  @override
  Future<void> onInit() async {
    super.onInit();
    print('🔧 ProblemServiceV2.onInit() 开始');
    await _initCache();
    await _loadIndex();
    print('🔧 ProblemServiceV2.onInit() 完成');
  }

  /// 初始化Hive缓存
  Future<void> _initCache() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(_cacheBoxName);
      print('✅ 题库缓存初始化成功');
    } catch (e) {
      print('❌ 缓存初始化失败: $e');
    }
  }

  /// 加载索引文件
  Future<void> _loadIndex() async {
    try {
      final String indexString =
          await rootBundle.loadString('assets/data/problems_index.json');
      _index = json.decode(indexString);
      print('📋 题库索引加载完成：${_index.length}个主题');
    } catch (e) {
      print('❌ 加载索引失败: $e');
      _index = {};
    }
  }

  /// 加载指定主题的题目
  Future<List<Problem>> loadTopicProblems(String topic) async {
    // 已加载过，直接返回
    if (_problemsByTopic.containsKey(topic)) {
      return _problemsByTopic[topic]!;
    }

    isLoading.value = true;
    loadingTopic.value = topic;
    final stopwatch = Stopwatch()..start();

    try {
      // 检查缓存
      final cacheKey = 'topic_$topic';
      final cachedVersion = _cacheBox?.get('${cacheKey}_version');

      if (cachedVersion == _cacheVersion && _cacheBox?.containsKey(cacheKey) == true) {
        // 从缓存读取
        print('📦 从缓存读取主题 [$topic]');
        final cachedData = _cacheBox!.get(cacheKey) as List;
        final problems = cachedData
            .map((json) => Problem.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        _problemsByTopic[topic] = problems;
        loadedTopics.add(topic);

        stopwatch.stop();
        print('✅ [$topic] 缓存加载：${problems.length}道题，耗时${stopwatch.elapsedMilliseconds}ms');
        return problems;
      }

      // 从assets加载
      final topicInfo = _index[topic];
      if (topicInfo == null) {
        print('⚠️  主题 [$topic] 不在索引中，加载所有题目');
        return await _loadAllProblems();
      }

      final filePath = 'assets/data/${topicInfo['file']}';
      print('📂 从assets加载主题 [$topic]: $filePath');

      final String jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> jsonData = json.decode(jsonString);
      final problems = jsonData.map((json) => Problem.fromJson(json)).toList();

      // 保存到缓存
      await _cacheBox?.put(cacheKey, jsonData);
      await _cacheBox?.put('${cacheKey}_version', _cacheVersion);

      _problemsByTopic[topic] = problems;
      loadedTopics.add(topic);

      stopwatch.stop();
      print('✅ [$topic] 加载并缓存：${problems.length}道题，耗时${stopwatch.elapsedMilliseconds}ms');
      return problems;
    } catch (e) {
      print('❌ 加载主题 [$topic] 失败: $e');
      return [];
    } finally {
      isLoading.value = false;
      loadingTopic.value = '';
    }
  }

  /// 加载所有题目（兜底方案）
  Future<List<Problem>> _loadAllProblems() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/problems.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => Problem.fromJson(json)).toList();
    } catch (e) {
      print('❌ 加载所有题目失败: $e');
      return [];
    }
  }

  /// 获取所有已加载的题目
  List<Problem> getAllProblems() {
    return _problemsByTopic.values.expand((list) => list).toList();
  }

  /// 获取指定主题的题目（自动加载）
  Future<List<Problem>> getProblemsByTopic(String topic) async {
    print('📖 getProblemsByTopic: $topic');
    if (topic == '全部') {
      // 加载所有主题
      print('📚 需要加载所有主题，索引中有: ${_index.keys.toList()}');
      await _loadAllTopics();
      final allProblems = getAllProblems();
      print('📚 所有主题加载完成: ${allProblems.length}道题');
      return allProblems;
    }
    return await loadTopicProblems(topic);
  }

  /// 加载所有主题
  Future<void> _loadAllTopics() async {
    final topics = _index.keys.toList();
    print('📋 开始加载所有主题: $topics');
    for (var topic in topics) {
      if (!loadedTopics.contains(topic)) {
        print('  → 加载主题: $topic');
        await loadTopicProblems(topic);
      } else {
        print('  ✓ 已加载: $topic');
      }
    }
  }

  /// 按主题和难度获取题目
  Future<List<Problem>> getProblemsByTopicAndDifficulty(
      String topic, String difficulty) async {
    final topicProblems = await getProblemsByTopic(topic);
    if (difficulty == '全部') {
      return topicProblems;
    }
    return topicProblems.where((p) => p.difficulty == difficulty).toList();
  }

  /// 按难度获取题目（需要加载所有主题）
  Future<List<Problem>> getProblemsByDifficulty(String difficulty) async {
    await _loadAllTopics();
    return getAllProblems().where((p) => p.difficulty == difficulty).toList();
  }

  /// 获取所有主题列表
  List<String> getAllTopics() {
    return _index.keys.toList()..sort();
  }

  /// 获取所有难度列表
  List<String> getAllDifficulties() {
    return ['L1', 'L2', 'L3'];
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await _cacheBox?.clear();
    _problemsByTopic.clear();
    loadedTopics.clear();
    print('🗑️  缓存已清除');
  }
}

