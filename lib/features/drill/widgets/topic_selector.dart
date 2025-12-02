import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drill_controller.dart';
import '../../../core/services/problem_service.dart';

class TopicSelector extends StatelessWidget {
  const TopicSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrillController>();
    final problemService = Get.find<ProblemService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButton<String>(
                  value: controller.selectedTopic.value,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: '全部', child: Text('全部主题')),
                    ...problemService.getAllTopics().map((topic) =>
                        DropdownMenuItem(value: topic, child: Text(topic))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setTopic(value);
                    }
                  },
                )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => DropdownButton<String>(
                  value: controller.selectedDifficulty.value,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: '全部', child: Text('全部难度')),
                    DropdownMenuItem(value: '基础', child: Text('基础')),
                    DropdownMenuItem(value: '进阶', child: Text('进阶')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setDifficulty(value);
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }
}






