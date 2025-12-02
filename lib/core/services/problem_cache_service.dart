import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/problem.dart';

/// 题库缓存服务（使用Hive提升性能）
class ProblemCacheService {
  static const String _boxName = 'problems_cache';
  static const String _versionKey = 'cache_version';
  static const String _currentVersion = '1.0'; // 题库版本号，更新题库时需要修改

  Box? _box;
  bool _isInitialized = false;

  /// 初始化Hive
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      print('✅ Hive缓存初始化成功');
    } catch (e) {
      print('❌ Hive初始化失败: $e');
    }
  }

  /// 加载题库（带缓存）
  Future<List<Problem>> loadProblems() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 确保Hive已初始化
      if (!_isInitialized) {
        await init();
      }

      // 检查缓存版本
      final cachedVersion = _box?.get(_versionKey);
      final hasCachedData = _box?.containsKey('problems') ?? false;

      if (cachedVersion == _currentVersion && hasCachedData) {
        // 从缓存读取
        print('📦 从缓存读取题库...');
        final cachedData = _box!.get('problems') as List;
        final problems = cachedData
            .map((json) => Problem.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        
        stopwatch.stop();
        print('✅ 缓存加载完成：${problems.length}道题，耗时${stopwatch.elapsedMilliseconds}ms');
        return problems;
      } else {
        // 从assets加载并缓存
        print('📚 从assets加载题库并缓存...');
        final String jsonString =
            await rootBundle.loadString('assets/data/problems.json');
        final List<dynamic> jsonData = json.decode(jsonString);
        final problems = jsonData.map((json) => Problem.fromJson(json)).toList();

        // 保存到缓存
        await _box?.put('problems', jsonData);
        await _box?.put(_versionKey, _currentVersion);
        
        stopwatch.stop();
        print('✅ 题库加载并缓存完成：${problems.length}道题，耗时${stopwatch.elapsedMilliseconds}ms');
        return problems;
      }
    } catch (e) {
      print('❌ 加载题库失败: $e');
      stopwatch.stop();
      return [];
    }
  }

  /// 清除缓存（用于强制刷新）
  Future<void> clearCache() async {
    try {
      await _box?.clear();
      print('🗑️  缓存已清除');
    } catch (e) {
      print('❌ 清除缓存失败: $e');
    }
  }

  /// 更新缓存版本（题库更新后调用）
  static const String cacheVersion = _currentVersion;
}

