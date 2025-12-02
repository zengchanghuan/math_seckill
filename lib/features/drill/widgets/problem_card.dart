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

    return Obx(() {
      final selectedAnswer = controller.userAnswers[problem.id];
      final answerStatus = controller.answerStatus[problem.id];
      final showSolution = controller.showSolution[problem.id] ?? false;

      // 获取选项列表
      final options = problem.options;

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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 题目展示区
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: Math.tex(
                            LatexHelper.cleanLatex(problem.question),
                            mathStyle: MathStyle.text,
                            textStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 根据题型显示不同的答题区域
                if (problem.type == 'choice' && options.isNotEmpty && options.length >= 4) ...[
                  // 选择题：选项区域
                  Text(
                    '请选择答案：',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(options.length, (index) {
                    final optionLabel =
                        String.fromCharCode(65 + index); // A, B, C, D
                    final isSelected = selectedAnswer == optionLabel;
                    final isCorrect = answerStatus == true && isSelected;
                    final isWrong = answerStatus == false && isSelected;
                    final isCorrectOption = problem.answer == optionLabel;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: answerStatus == null
                            ? () {
                                controller.selectAnswer(
                                    problem.id, optionLabel);
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isCorrect
                                    ? Colors.green.shade100
                                    : isWrong
                                        ? Colors.red.shade100
                                        : Colors.blue.shade100)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrect
                                      ? Colors.green
                                      : isWrong
                                          ? Colors.red
                                          : Colors.blue)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // 选项标签 (A, B, C, D)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isCorrect
                                          ? Colors.green
                                          : isWrong
                                              ? Colors.red
                                              : Colors.blue)
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    optionLabel,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 选项内容
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth,
                                        ),
                                        child: Math.tex(
                                          LatexHelper.cleanLatex(
                                              options[index]),
                                          mathStyle: MathStyle.text,
                                          textStyle: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // 状态图标
                              if (answerStatus != null && isCorrectOption)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                )
                              else if (answerStatus != null && isWrong)
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ] else if (problem.type == 'fill') ...[
                  // 填空题：文本输入框
                  Text(
                    '请输入答案：',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    enabled: answerStatus == null,
                    decoration: InputDecoration(
                      hintText: '请输入数值或表达式',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: answerStatus == null
                          ? Colors.white
                          : (answerStatus == true
                              ? Colors.green.shade50
                              : Colors.red.shade50),
                      prefixIcon: Icon(
                        answerStatus == null
                            ? Icons.edit
                            : (answerStatus == true
                                ? Icons.check_circle
                                : Icons.cancel),
                        color: answerStatus == null
                            ? Colors.grey
                            : (answerStatus == true ? Colors.green : Colors.red),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                    onChanged: (value) {
                      controller.setAnswer(problem.id, value);
                    },
                    onSubmitted: (value) {
                      if (answerStatus == null) {
                        controller.checkFillAnswer(problem.id);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (answerStatus == null)
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.checkFillAnswer(problem.id);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('提交答案'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ] else if (problem.type == 'solution') ...[
                  // 解答题：多行文本输入框
                  Text(
                    '请输入最终答案：',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '提示：解答题只判最终答案，请在最后写出明确的答案',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    enabled: answerStatus == null,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '请输入最终答案（数值或表达式）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: answerStatus == null
                          ? Colors.white
                          : (answerStatus == true
                              ? Colors.green.shade50
                              : Colors.red.shade50),
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(fontSize: 18),
                    onChanged: (value) {
                      controller.setAnswer(problem.id, value);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (answerStatus == null)
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.checkSolutionAnswer(problem.id);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('提交答案'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                // 答案反馈区域
                if (answerStatus != null) ...[
                  // 错误答案提示：显示正确答案
                  if (answerStatus == false) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.shade300, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                problem.type == 'choice'
                                    ? '正确答案是：选项 ${problem.answer}'
                                    : '正确答案是：${problem.answer}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 显示正确答案的内容
                          if (options.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.orange.shade400),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade700,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        problem.answer,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final correctIndex =
                                            problem.answer.codeUnitAt(0) - 65;
                                        if (correctIndex >= 0 &&
                                            correctIndex < options.length) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: constraints.maxWidth,
                                              ),
                                              child: Math.tex(
                                                LatexHelper.cleanLatex(
                                                    options[correctIndex]),
                                                mathStyle: MathStyle.text,
                                                textStyle: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextButton.icon(
                        onPressed: () => controller.toggleSolution(problem.id),
                        icon: Icon(showSolution
                            ? Icons.visibility_off
                            : Icons.visibility),
                        label: Text(showSolution ? '隐藏解答' : '查看解答'),
                      ),
                    ),
                  ],
                  if (showSolution) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: Math.tex(
                                    LatexHelper.cleanLatex(problem.solution),
                                    mathStyle: MathStyle.text,
                                    textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
