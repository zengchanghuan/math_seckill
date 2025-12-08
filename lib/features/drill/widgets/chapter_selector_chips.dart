import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';

/// 章节选择器 - 芯片按钮样式
class ChapterSelectorChips extends GetView<DrillController> {
  const ChapterSelectorChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chapters = controller.getChaptersForCurrentTheme();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '选择章节',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chapters.map((chapter) {
                final isSelected = controller.selectedChapter.value == chapter;

                return ChoiceChip(
                  label: Text(
                    chapter,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.setChapter(chapter);
                    }
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey.shade100,
                  elevation: isSelected ? 2 : 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}





