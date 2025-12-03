import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/config_service.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final apiService = Get.find<ApiService>();
    final configService = Get.find<ConfigService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 配置同步状态
          const ListTile(
            title: Text('配置同步', style: TextStyle(fontWeight: FontWeight.bold)),
            enabled: false,
          ),
          Obx(() => ListTile(
            leading: Icon(
              configService.usingServerConfig.value
                  ? Icons.cloud_done
                  : Icons.cloud_off,
              color: configService.usingServerConfig.value
                  ? Colors.green
                  : Colors.orange,
            ),
            title: const Text('配置来源'),
            subtitle: Text(configService.getConfigInfo()),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                final success = await configService.refresh();
                Get.back();

                Get.snackbar(
                  success ? '成功' : '失败',
                  success
                      ? '配置已更新到最新版本'
                      : '无法连接服务器，使用缓存配置',
                  backgroundColor: success ? Colors.green : Colors.orange,
                  colorText: Colors.white,
                );
              },
            ),
          )),
          const Divider(),

          // 用户设置
          const ListTile(
            title: Text('用户设置', style: TextStyle(fontWeight: FontWeight.bold)),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('学生ID'),
            subtitle: Obx(() => Text(apiService.currentStudentId.value)),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showStudentIdDialog(context, apiService, storageService);
            },
          ),
          const Divider(),

          // 服务器设置
          const ListTile(
            title: Text('服务器设置', style: TextStyle(fontWeight: FontWeight.bold)),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('服务器地址'),
            subtitle: Obx(() => Text(apiService.serverUrl.value)),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showServerUrlDialog(context, apiService, storageService);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('测试连接'),
            onTap: () async {
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final success = await apiService.healthCheck();
              Get.back(); // 关闭加载对话框

              Get.snackbar(
                success ? '成功' : '失败',
                success ? '服务器连接正常' : '无法连接到服务器',
                backgroundColor: success ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.offline_bolt),
            title: const Text('离线模式'),
            subtitle: const Text('离线时使用本地数据'),
            value: storageService.isOfflineMode(),
            onChanged: (value) {
              storageService.setOfflineMode(value);
              Get.snackbar(
                '提示',
                value ? '已切换到离线模式' : '已切换到在线模式',
              );
            },
          ),
          const Divider(),

          // 显示设置
          const ListTile(
            title: Text('显示设置', style: TextStyle(fontWeight: FontWeight.bold)),
            enabled: false,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: const Text('自动显示解析'),
            subtitle: const Text('答题后自动显示题目解析'),
            value: storageService.isShowSolution(),
            onChanged: (value) {
              storageService.setShowSolution(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            subtitle: const Text('使用深色主题'),
            value: storageService.isDarkMode(),
            onChanged: (value) {
              storageService.setDarkMode(value);
              Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const Divider(),

          // 关于
          const ListTile(
            title: Text('关于', style: TextStyle(fontWeight: FontWeight.bold)),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于应用'),
            subtitle: const Text('数学秒杀 v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '数学秒杀',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.calculate, size: 48),
                children: [
                  const Text('基于后端 v2.0 的智能刷题应用'),
                  const SizedBox(height: 8),
                  const Text('功能特色：'),
                  const Text('• 个性化题目推荐'),
                  const Text('• 学习画像分析'),
                  const Text('• 数据驱动的学习优化'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 显示学生ID输入对话框
  void _showStudentIdDialog(
    BuildContext context,
    ApiService apiService,
    StorageService storageService,
  ) {
    final controller = TextEditingController(text: apiService.currentStudentId.value);

    Get.defaultDialog(
      title: '设置学生ID',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '学生ID',
            hintText: '例如：student_001',
          ),
        ),
      ),
      textConfirm: '确认',
      textCancel: '取消',
      onConfirm: () {
        final newId = controller.text.trim();
        if (newId.isNotEmpty) {
          apiService.setStudentId(newId);
          storageService.setStudentId(newId);
          Navigator.of(Get.overlayContext!).pop();
          Future.delayed(const Duration(milliseconds: 100), () {
            Get.snackbar('成功', '学生ID已更新');
          });
        }
      },
    );
  }

  /// 显示服务器地址输入对话框
  void _showServerUrlDialog(
    BuildContext context,
    ApiService apiService,
    StorageService storageService,
  ) {
    final controller = TextEditingController(text: apiService.serverUrl.value);

    Get.defaultDialog(
      title: '设置服务器地址',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '服务器地址',
            hintText: 'http://192.168.2.1:8000（Mac热点）',
          ),
        ),
      ),
      textConfirm: '确认',
      textCancel: '取消',
      onConfirm: () {
        final newUrl = controller.text.trim();
        if (newUrl.isNotEmpty) {
          apiService.setServerUrl(newUrl);
          storageService.setServerUrl(newUrl);
          Navigator.of(Get.overlayContext!).pop();
          Future.delayed(const Duration(milliseconds: 100), () {
            Get.snackbar('成功', '服务器地址已更新');
          });
        }
      },
    );
  }
}

