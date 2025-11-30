import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/formula_controller.dart';

class FormulaSearchBar extends StatelessWidget {
  const FormulaSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FormulaController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索公式...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.setSearchQuery('');
                  },
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          controller.setSearchQuery(value);
        },
      ),
    );
  }
}

