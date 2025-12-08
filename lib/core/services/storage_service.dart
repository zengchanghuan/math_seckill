import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ==================== 用户设置 ====================

  /// 获取学生ID
  String? getStudentId() {
    return _prefs.getString('student_id');
  }

  /// 设置学生ID
  Future<bool> setStudentId(String studentId) {
    return _prefs.setString('student_id', studentId);
  }

  /// 获取服务器地址（Mac热点模式）
  String getServerUrl() {
    return _prefs.getString('server_url') ?? 'http://192.168.2.1:8000';
  }

  /// 设置服务器地址
  Future<bool> setServerUrl(String url) {
    return _prefs.setString('server_url', url);
  }

  // ==================== 离线模式 ====================

  /// 是否启用离线模式
  bool isOfflineMode() {
    return _prefs.getBool('offline_mode') ?? false;
  }

  /// 设置离线模式
  Future<bool> setOfflineMode(bool enabled) {
    return _prefs.setBool('offline_mode', enabled);
  }

  // ==================== 学习记录（离线时使用）====================

  /// 保存离线作答记录
  Future<bool> saveOfflineAnswer(String recordJson) async {
    final records = getOfflineAnswers();
    records.add(recordJson);
    return _prefs.setStringList('offline_answers', records);
  }

  /// 获取离线作答记录
  List<String> getOfflineAnswers() {
    return _prefs.getStringList('offline_answers') ?? [];
  }

  /// 清空离线作答记录
  Future<bool> clearOfflineAnswers() {
    return _prefs.remove('offline_answers');
  }

  // ==================== 主题设置 ====================

  /// 获取主题模式（true=深色，false=浅色）
  bool isDarkMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  /// 设置主题模式
  Future<bool> setDarkMode(bool isDark) {
    return _prefs.setBool('dark_mode', isDark);
  }

  // ==================== 其他设置 ====================

  /// 是否显示解析
  bool isShowSolution() {
    return _prefs.getBool('show_solution') ?? true;
  }

  /// 设置是否显示解析
  Future<bool> setShowSolution(bool show) {
    return _prefs.setBool('show_solution', show);
  }

  /// 获取默认推荐模式
  String getDefaultRecommendMode() {
    return _prefs.getString('default_recommend_mode') ?? 'weak_points';
  }

  /// 设置默认推荐模式
  Future<bool> setDefaultRecommendMode(String mode) {
    return _prefs.setString('default_recommend_mode', mode);
  }

  // ==================== 配置缓存 ====================

  /// 保存配置缓存
  Future<bool> setCachedConfig(String configJson) {
    return _prefs.setString('cached_theme_config', configJson);
  }

  /// 获取配置缓存
  String? getCachedConfig() {
    return _prefs.getString('cached_theme_config');
  }

  /// 保存配置更新时间
  Future<bool> setCachedConfigTime(String time) {
    return _prefs.setString('cached_config_time', time);
  }

  /// 获取配置更新时间
  String? getCachedConfigTime() {
    return _prefs.getString('cached_config_time');
  }
}
