import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/formula_service.dart';
import '../../formulas/controllers/formula_controller.dart';
import '../../formulas/widgets/formula_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formulaController = Get.find<FormulaController>();
    final formulaService = Get.find<FormulaService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
      ),
      body: Obx(() {
        final favoriteIds = formulaController.favoriteFormulaIds;
        
        if (favoriteIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无收藏',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '在公式页面点击心形图标收藏公式',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        final favoriteFormulas = favoriteIds
            .map((id) => formulaService.getFormulaById(id))
            .where((f) => f != null)
            .cast()
            .toList();

        return ListView.builder(
          itemCount: favoriteFormulas.length,
          itemBuilder: (context, index) {
            return FormulaCard(formula: favoriteFormulas[index]);
          },
        );
      }),
    );
  }
}

