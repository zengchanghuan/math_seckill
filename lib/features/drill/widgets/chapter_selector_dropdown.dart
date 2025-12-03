import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';

/// 章节选择器 - 下拉框样式
class ChapterSelectorDropdown extends GetView<DrillController> {
  const ChapterSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chapters = controller.getChaptersForCurrentTheme();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            const Icon(Icons.menu_book, size: 20, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              '章节：',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: controller.selectedChapter.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  items: chapters.map((chapter) {
                    return DropdownMenuItem(
                      value: chapter,
                      child: Text(
                        chapter,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setChapter(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

