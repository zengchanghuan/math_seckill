import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/problem.dart';
import '../../../core/models/training_instance.dart';
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
  final String _difficulty = 'L1'; // 固定为"L1"
  String? _selectedChapter;
  String? _selectedSection;

  // 用户实例层
  TrainingInstance? _currentInstance;
  List<Problem> _instanceProblems = [];
  int _currentQuestionIndex = 0;

  Problem? get _currentProblem {
    if (_instanceProblems.isEmpty || _currentQuestionIndex >= _instanceProblems.length) {
      return null;
    }
    return _instanceProblems[_currentQuestionIndex];
  }

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

      setState(() {
        _isInitialized = true;
      });

      if (selectedTheme != null) {
        setState(() {
          _topic = selectedTheme;
        });
        // 如果主题有章节结构，自动选择第一章和第一节
        if (_currentTopicStructure != null && _currentTopicStructure!.chapters.isNotEmpty) {
          _selectedChapter = _currentTopicStructure!.chapters.first.name;
          if (_currentTopicStructure!.chapters.first.sections.isNotEmpty) {
            _selectedSection = _currentTopicStructure!.chapters.first.sections.first.name;
          }
        }
        // 延迟加载训练实例，不阻塞UI显示
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _loadOrCreateInstance();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isInitialized = true;
        _error = e.toString();
      });
    }
  }

  /// 加载或创建训练实例
  Future<void> _loadOrCreateInstance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // 构建实例key（基于主题、章节、节）
      final instanceKey = 'training_instance_${_topic}_${_selectedChapter ?? 'none'}_${_selectedSection ?? 'none'}';
      final savedInstanceId = prefs.getString(instanceKey);

      if (savedInstanceId != null) {
        // 尝试加载已有实例
        print('🔍 查找已有实例: $savedInstanceId');
        try {
          final data = await _remoteService.getTrainingInstance(savedInstanceId);
          final instance = TrainingInstance.fromJson(data['instance']);
          final questions = (data['questions'] as List)
              .map((q) => Problem.fromJson(q))
              .toList();

          setState(() {
            _currentInstance = instance;
            _instanceProblems = questions;
            _currentQuestionIndex = 0;
          });
          print('✅ 已加载实例：${questions.length}道题');
          return;
        } catch (e) {
          print('⚠️  加载实例失败，将创建新实例: $e');
          // 加载失败，清除旧ID，创建新实例
          await prefs.remove(instanceKey);
        }
      }

      // 创建新实例
      print('📝 创建新训练实例...');
      final data = await _remoteService.createTrainingInstance(
        topic: _topic,
        difficulty: _difficulty,
        chapter: _selectedChapter,
        section: _selectedSection,
        questionCount: 20,
      );

      final instance = TrainingInstance.fromJson(data['instance']);
      final questions = (data['questions'] as List)
          .map((q) => Problem.fromJson(q))
          .toList();

      // 保存实例ID
      await prefs.setString(instanceKey, instance.instanceId);

      setState(() {
        _currentInstance = instance;
        _instanceProblems = questions;
        _currentQuestionIndex = 0;
      });
      print('✅ 创建实例成功：${questions.length}道题');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      print('❌ 加载/创建实例失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 下一题
  void _nextQuestion() {
    if (_currentQuestionIndex < _instanceProblems.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  /// 上一题
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  /// 开始新一轮训练（重新生成实例）
  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final instanceKey = 'training_instance_${_topic}_${_selectedChapter ?? 'none'}_${_selectedSection ?? 'none'}';

    // 清除旧实例
    await prefs.remove(instanceKey);

    // 重新加载
    await _loadOrCreateInstance();
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
                          _loadOrCreateInstance();
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
                      _loadOrCreateInstance();
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
            Row(
              children: [
                // 上一题按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestionIndex > 0 && !_isLoading
                        ? _previousQuestion
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('上一题'),
                  ),
                ),
                const SizedBox(width: 12),
                // 下一题按钮
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestionIndex < _instanceProblems.length - 1 && !_isLoading
                        ? _nextQuestion
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_currentQuestionIndex < _instanceProblems.length - 1
                        ? '下一题 (${_currentQuestionIndex + 2}/${_instanceProblems.length})'
                        : '已完成'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 开始新一轮训练
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _startNewTraining,
                icon: const Icon(Icons.refresh),
                label: const Text('开始新一轮训练'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _currentInstance == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_currentProblem == null) {
      return const Center(child: Text('暂无题目'));
    }

    final p = _currentProblem!;
    final progress = _currentInstance != null
        ? '${_currentQuestionIndex + 1}/${_instanceProblems.length}'
        : '';

    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 显示进度和难度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${p.topic} · ${p.difficulty}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (progress.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        progress,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                ],
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


