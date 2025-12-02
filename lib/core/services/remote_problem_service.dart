import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/problem.dart';
import 'api_config.dart';

class RemoteProblemService {
  /// 打印网络请求日志
  void _log(String message) {
    // 使用 print 输出日志，方便在 Xcode Console 和终端查看
    print('[网络请求] $message');
  }

  /// 测试后端连接是否正常
  Future<Map<String, dynamic>> testConnection() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/');
    _log('开始测试连接: $uri');

    try {
      _log('发送 GET 请求到: $uri');
      _log('请求头: {Accept: application/json}');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('请求超时（5秒）');
          throw Exception('连接超时，请检查后端服务器是否启动');
        },
      );

      _log('收到响应:');
      _log('  状态码: ${response.statusCode}');
      _log('  响应头: ${response.headers}');
      _log('  响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log('连接成功 ✅');
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': '连接成功 ✅\n后端地址: ${ApiConfig.baseUrl}',
          'data': data,
        };
      } else {
        _log('连接失败: ${response.statusCode} ${response.reasonPhrase}');
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': '连接失败: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e, stackTrace) {
      _log('请求异常: $e');
      _log('堆栈跟踪: $stackTrace');

      String errorMsg = '连接错误: $e';
      if (e.toString().contains('Connection refused')) {
        errorMsg = '连接被拒绝\n\n可能原因：\n1. 后端服务器未启动\n2. 端口配置不正确\n3. 网络权限问题\n4. 真机需要使用 Mac 的 IP 地址（不是 localhost）\n\n请检查后端是否运行在 ${ApiConfig.baseUrl}';
      } else if (e.toString().contains('timeout')) {
        errorMsg = '连接超时\n\n请检查：\n1. 后端服务器是否正常运行\n2. 网络连接是否正常\n3. 真机和 Mac 是否在同一网络';
      } else if (e.toString().contains('Network is unreachable')) {
        errorMsg = '网络不可达\n\n请检查：\n1. 真机和 Mac 是否在同一 Wi-Fi 网络\n2. Mac 防火墙是否阻止了连接\n3. 使用 Mac 的实际 IP 地址（不是 localhost）';
      }
      return {
        'success': false,
        'statusCode': 0,
        'message': errorMsg,
      };
    }
  }

  Future<Problem> fetchProblem({
    required String topic,
    required String difficulty,
    String? chapter,
    String? section,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/problem');
    final requestBody = {
      'topic': topic,
      'difficulty': difficulty,
      if (chapter != null) 'chapter': chapter,
      if (section != null) 'section': section,
    };

    _log('开始获取题目');
    _log('请求 URL: $uri');
    _log('请求体: $requestBody');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _log('获取题目超时（10秒）');
          throw Exception('获取题目超时，请检查网络连接');
        },
      );

      _log('收到响应:');
      _log('  状态码: ${response.statusCode}');
      _log('  响应头: ${response.headers}');
      _log('  响应体长度: ${response.body.length} 字符');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _log('解析成功，题目 ID: ${data['id']}');
        return Problem.fromJson(data);
      } else {
        _log('获取题目失败: ${response.statusCode} ${response.reasonPhrase}');
        _log('响应体: ${response.body}');
        throw Exception(
            '获取题目失败: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      _log('获取题目异常: $e');
      _log('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}



