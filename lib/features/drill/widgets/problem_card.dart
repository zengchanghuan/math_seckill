import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../utils/latex_helper.dart';
import '../controllers/drill_controller.dart';
import '../../../core/models/problem.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;

  const ProblemCard({
    super.key,
    required this.problem,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrillController>();
    final answerController = TextEditingController(
      text: controller.userAnswers[problem.id] ?? '',
    );

    return Obx(() {
      final answerStatus = controller.answerStatus[problem.id];
      final showSolution = controller.showSolution[problem.id] ?? false;
      final hasAnswer = answerController.text.isNotEmpty;

      Color cardColor = Colors.white;
      if (answerStatus == true) {
        cardColor = Colors.green.shade50;
      } else if (answerStatus == false) {
        cardColor = Colors.red.shade50;
      }

      return Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 题目展示区
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  LatexHelper.cleanLatex(problem.question),
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 答案输入区
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: '请输入答案',
                  hintText: '例如: 2x+3, cos(x), 1/2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: answerStatus != null
                      ? Icon(
                          answerStatus ? Icons.check_circle : Icons.cancel,
                          color: answerStatus ? Colors.green : Colors.red,
                        )
                      : null,
                ),
                onChanged: (value) {
                  controller.setAnswer(problem.id, value);
                },
                enabled: answerStatus == null,
              ),
              const SizedBox(height: 24),

              // 操作按钮区
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (answerStatus == null && hasAnswer)
                    ElevatedButton.icon(
                      onPressed: () => controller.checkAnswer(problem.id),
                      icon: const Icon(Icons.check),
                      label: const Text('检查'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (answerStatus != null)
                    TextButton.icon(
                      onPressed: () => controller.toggleSolution(problem.id),
                      icon: Icon(showSolution ? Icons.visibility_off : Icons.visibility),
                      label: Text(showSolution ? '隐藏答案' : '查看答案'),
                    ),
                  if (answerStatus != null)
                    ElevatedButton.icon(
                      onPressed: () => controller.nextProblem(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('下一题'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),

              // 解答展示区
              if (showSolution) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '解答：',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Math.tex(
                        LatexHelper.cleanLatex(problem.solution),
                        mathStyle: MathStyle.text,
                        textStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

