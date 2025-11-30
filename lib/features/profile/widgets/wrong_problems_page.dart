import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../utils/latex_helper.dart';
import '../../../core/services/problem_service.dart';
import '../../drill/controllers/drill_controller.dart';

class WrongProblemsPage extends StatelessWidget {
  const WrongProblemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final drillController = Get.find<DrillController>();
    final problemService = Get.find<ProblemService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
      ),
      body: Obx(() {
        final wrongIds = drillController.wrongProblemIds;

        if (wrongIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无错题',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '继续保持，加油！',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        final wrongProblems = wrongIds
            .map((id) => problemService.getProblemById(id))
            .where((p) => p != null)
            .cast()
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wrongProblems.length,
          itemBuilder: (context, index) {
            final problem = wrongProblems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text('题目 ${index + 1}'),
                subtitle: Text('${problem.topic} - ${problem.difficulty}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Math.tex(
                            LatexHelper.cleanLatex(problem.question),
                            mathStyle: MathStyle.text,
                            textStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '正确答案：',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                problem.answer,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '解答：',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Math.tex(
                                LatexHelper.cleanLatex(problem.solution),
                                mathStyle: MathStyle.text,
                                textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

