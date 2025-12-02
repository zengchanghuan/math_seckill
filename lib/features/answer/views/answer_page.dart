import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/problem.dart';
import '../../../core/services/remote_problem_service.dart';
import '../../../utils/latex_helper.dart';
import '../../../core/data/topic_structure.dart';

class AnswerPage extends StatefulWidget {
  const AnswerPage({super.key});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  final _remoteService = RemoteProblemService();

  String _topic = '导数基础'; // 从 SharedPreferences 读取
  final String _difficulty = '基础'; // 固定为"基础"
  String? _selectedChapter;
  String? _selectedSection;

  Problem? _problem;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  TopicStructure? get _currentTopicStructure => getTopicStructure(_topic);
  List<Chapter> get _availableChapters => _currentTopicStructure?.chapters ?? [];
  List<Section> get _availableSections {
    if (_selectedChapter == null || _currentTopicStructure == null) {
      return [];
    }
    final chapter = _currentTopicStructure!.chapters.firstWhere(
      (ch) => ch.name == _selectedChapter,
      orElse: () => _currentTopicStructure!.chapters.first,
    );
    return chapter.sections;
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedTheme = prefs.getString('selected_theme');
      if (selectedTheme != null) {
        setState(() {
          _topic = selectedTheme;
          _isInitialized = true;
        });
        // 如果主题有章节结构，自动选择第一章和第一节
        if (_currentTopicStructure != null && _currentTopicStructure!.chapters.isNotEmpty) {
          _selectedChapter = _currentTopicStructure!.chapters.first.name;
          if (_currentTopicStructure!.chapters.first.sections.isNotEmpty) {
            _selectedSection = _currentTopicStructure!.chapters.first.sections.first.name;
          }
        }
        // 无论是否有章节结构，都自动加载第一道题
        _loadProblem();
      } else {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadProblem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final p = await _remoteService.fetchProblem(
        topic: _topic,
        difficulty: _difficulty,
        chapter: _selectedChapter,
        section: _selectedSection,
      );
      setState(() {
        _problem = p;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('解答'),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 如果当前主题有章节结构，显示章节和节选择器
                  if (_currentTopicStructure != null) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedChapter,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '章节',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('请选择章节'),
                      items: _availableChapters.map((chapter) {
                        return DropdownMenuItem(
                          value: chapter.name,
                          child: Text(
                            chapter.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedChapter = value;
                          _selectedSection = null; // 切换章节时重置节
                        });
                        if (value != null) {
                          _loadProblem();
                        }
                      },
                    ),
                    if (_selectedChapter != null) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedSection,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '节',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        hint: const Text('请选择节'),
                        items: _availableSections.map((section) {
                          return DropdownMenuItem(
                            value: section.name,
                            child: Text(
                              section.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value;
                          });
                          if (value != null) {
                            _loadProblem();
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
            Expanded(
              child: _buildContent(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadProblem,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('再来一题'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _problem == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_problem == null) {
      return const Center(child: Text('暂无题目'));
    }

    final p = _problem!;

    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 显示主题和难度
              Text(
                '${p.topic} · ${p.difficulty}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // 如果有章节和节，显示它们
              if (p.chapter != null || p.section != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if (p.chapter != null) p.chapter,
                    if (p.section != null) p.section,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
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
                          LatexHelper.cleanLatex(p.question),
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
              const SizedBox(height: 16),
              if (p.options.isNotEmpty) ...[
                const Text(
                  '选项',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < p.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${String.fromCharCode(65 + i)}. ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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
                                    LatexHelper.cleanLatex(p.options[i]),
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
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  '正确答案：${p.answer}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ExpansionTile(
                title: const Text('查看解析'),
                initiallyExpanded: true,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
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
                        _buildSolutionWidget(p.solution),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建解析内容的 Widget，带错误处理
  Widget _buildSolutionWidget(String solution) {
    // 将 solution 按段落分割（处理 \\[6pt] 等分隔符）
    final parts = solution.split(RegExp(r'\\\\\[.*?\]|\\\[.*?\]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        final cleanedPart = LatexHelper.cleanLatex(part.trim());
        if (cleanedPart.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Builder(
            builder: (context) {
              try {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Math.tex(
                          cleanedPart,
                          mathStyle: MathStyle.text,
                          textStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                // 如果单个段落渲染失败，显示为文本
                print('[解答段落渲染错误] $e');
                print('[段落内容] $cleanedPart');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cleanedPart,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }
}


