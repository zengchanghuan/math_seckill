import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/formula_controller.dart';
import '../widgets/search_bar.dart';
import '../widgets/formula_card.dart';
import '../../../core/services/formula_service.dart';

class FormulaListPage extends StatelessWidget {
  const FormulaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FormulaController());
    final formulaService = Get.find<FormulaService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('公式'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: FormulaSearchBar(),
        ),
      ),
      body: Obx(() {
        if (formulaService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredFormulas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '未找到公式',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请尝试其他搜索关键词',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 分类选择器
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('全部', controller),
                  const SizedBox(width: 8),
                  ...formulaService.getAllCategories().map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(category, controller),
                        ),
                      ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 公式列表
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredFormulas.length,
                itemBuilder: (context, index) {
                  return FormulaCard(
                    formula: controller.filteredFormulas[index],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryChip(String category, FormulaController controller) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      return FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.setCategory(category);
          }
        },
      );
    });
  }
}






