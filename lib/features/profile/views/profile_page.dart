import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/stats_card.dart';
import '../widgets/wrong_problems_page.dart';
import '../widgets/favorites_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('我'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshStats();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const StatsCard(),
            const SizedBox(height: 8),
            _buildFunctionList(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionList(
      BuildContext context, ProfileController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.error_outline,
            title: '错题本',
            subtitle: '查看做错的题目',
            onTap: () {
              Get.to(() => const WrongProblemsPage());
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            icon: Icons.favorite,
            title: '收藏夹',
            subtitle: '查看收藏的公式',
            onTap: () {
              Get.to(() => const FavoritesPage());
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            icon: Icons.palette,
            title: '主题设置',
            subtitle: '深色/浅色模式',
            onTap: () {
              _showThemeDialog(context, controller);
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            icon: Icons.text_fields,
            title: '字体大小',
            subtitle: '调整文字显示大小',
            onTap: () {
              _showFontSizeDialog(context, controller);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题设置'),
        content: Obx(() => SwitchListTile(
              title: const Text('深色模式'),
              subtitle:
                  Text(controller.isDarkMode.value ? '当前使用深色主题' : '当前使用浅色主题'),
              value: controller.isDarkMode.value,
              onChanged: (value) {
                controller.toggleDarkMode();
              },
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字体大小'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '当前字体大小: ${controller.fontSize.value.toInt()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: controller.fontSize.value,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: controller.fontSize.value.toInt().toString(),
                  onChanged: (value) {
                    controller.setFontSize(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '12',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '24',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

}
