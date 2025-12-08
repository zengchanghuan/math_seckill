import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/theme_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 配置同步服务 - 从后端获取主题配置
class ConfigService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // 当前使用的主题配置列表
  final RxList<ThemeConfig> themes = <ThemeConfig>[].obs;

  // 配置版本
  final RxString configVersion = 'unknown'.obs;

  // 最后更新时间
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  // 是否使用服务器配置
  final RxBool usingServerConfig = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时先加载默认配置
    _loadDefaultConfig();
    // 然后尝试从服务器同步
    syncFromServer();
  }

  /// 加载默认配置（内置，离线备份）
  void _loadDefaultConfig() {
    themes.value = ThemeConfigs.getAllConfigs();
    usingServerConfig.value = false;
  }

  /// 从服务器同步配置
  Future<bool> syncFromServer() async {
    try {
      final response = await http
          .get(
            Uri.parse('${_apiService.serverUrl.value}/api/config/themes'),
            headers: _apiService.headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 解析主题配置
        final List<dynamic> themesData = data['themes'] as List;
        final serverThemes = themesData
            .map((t) => ThemeConfig.fromJson(t as Map<String, dynamic>))
            .toList();

        // 更新配置
        themes.value = serverThemes;
        configVersion.value = data['version'] as String? ?? 'unknown';
        lastUpdated.value = DateTime.now();
        usingServerConfig.value = true;

        // 保存到本地缓存
        await _saveToCache(data);

        print('✅ 配置同步成功：版本 ${configVersion.value}');
        return true;
      } else {
        print('⚠️ 配置同步失败：HTTP ${response.statusCode}');
        // 尝试从缓存加载
        await _loadFromCache();
        return false;
      }
    } catch (e) {
      print('⚠️ 配置同步失败：$e');
      // 尝试从缓存加载
      await _loadFromCache();
      return false;
    }
  }

  /// 保存配置到本地缓存
  Future<void> _saveToCache(Map<String, dynamic> config) async {
    try {
      final configJson = json.encode(config);
      await _storageService.setCachedConfig(configJson);
      await _storageService
          .setCachedConfigTime(DateTime.now().toIso8601String());
    } catch (e) {
      print('保存配置缓存失败：$e');
    }
  }

  /// 从本地缓存加载配置
  Future<void> _loadFromCache() async {
    try {
      final cachedConfig = _storageService.getCachedConfig();
      final cachedTime = _storageService.getCachedConfigTime();

      if (cachedConfig != null) {
        final data = json.decode(cachedConfig) as Map<String, dynamic>;
        final List<dynamic> themesData = data['themes'] as List;
        final cachedThemes = themesData
            .map((t) => ThemeConfig.fromJson(t as Map<String, dynamic>))
            .toList();

        themes.value = cachedThemes;
        configVersion.value = data['version'] as String? ?? 'cached';

        if (cachedTime != null) {
          lastUpdated.value = DateTime.parse(cachedTime);
        }

        usingServerConfig.value = true; // 使用的是服务器配置的缓存版本
        print('📦 已加载缓存配置：版本 ${configVersion.value}');
      } else {
        // 没有缓存，使用默认配置
        _loadDefaultConfig();
        print('📱 使用内置默认配置');
      }
    } catch (e) {
      print('加载缓存配置失败：$e，使用默认配置');
      _loadDefaultConfig();
    }
  }

  /// 获取主题配置
  ThemeConfig? getThemeConfig(String themeName) {
    try {
      return themes.firstWhere((t) => t.name == themeName);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有主题配置
  List<ThemeConfig> getAllThemes() {
    return themes.toList();
  }

  /// 手动刷新配置
  Future<bool> refresh() async {
    return await syncFromServer();
  }

  /// 获取配置信息字符串
  String getConfigInfo() {
    if (usingServerConfig.value) {
      final time = lastUpdated.value;
      final timeStr = time != null
          ? '${time.month}/${time.day} ${time.hour}:${time.minute}'
          : '未知';
      return '服务器配置 v${configVersion.value} (更新于 $timeStr)';
    } else {
      return '内置默认配置';
    }
  }
}
