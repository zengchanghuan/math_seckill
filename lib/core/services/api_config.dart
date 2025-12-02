class ApiConfig {
  /// 后端服务器地址配置
  ///
  /// - iOS 模拟器: 使用 localhost 或 127.0.0.1
  /// - iOS 真机: 使用 Mac 的实际 IP 地址（例如: 192.168.231.26）
  /// - Android 模拟器: 使用 10.0.2.2
  ///
  /// 获取 Mac IP 地址: 在终端运行 `ifconfig | grep "inet " | grep -v 127.0.0.1`
  ///
  /// 当前使用 Mac 热点 IP（bridge0 接口）
  static const String baseUrl = 'http://192.168.3.1:8000';

  /// 开发环境配置（可选）
  /// 如果需要快速切换，可以取消注释下面的配置：
  // static const String baseUrl = 'http://127.0.0.1:8000'; // iOS 模拟器
  // static const String baseUrl = 'http://localhost:8000'; // iOS 模拟器
}



