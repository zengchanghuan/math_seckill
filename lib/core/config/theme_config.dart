/// 学习主题配置 - 定义每个主题的章节和题目分配规则
class ThemeConfig {
  final String name;
  final String icon;
  final int totalQuestions;
  final Map<String, double> difficultyDistribution; // Easy, Medium, Hard
  final List<ChapterConfig> chapters;

  const ThemeConfig({
    required this.name,
    required this.icon,
    required this.totalQuestions,
    required this.difficultyDistribution,
    required this.chapters,
  });

  /// 从 JSON 创建
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      name: json['name'] as String,
      icon: json['icon'] as String,
      totalQuestions: json['totalQuestions'] as int,
      difficultyDistribution: Map<String, double>.from(
        (json['difficultyDistribution'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      chapters: (json['chapters'] as List)
          .map((c) => ChapterConfig.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'totalQuestions': totalQuestions,
      'difficultyDistribution': difficultyDistribution,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }
}

/// 章节配置
class ChapterConfig {
  final String chapterName;
  final String importance; // 最高、极高、高、基础、低
  final int suggestedQuestions;
  final double percentage;
  final Map<String, double> difficultyDistribution; // Easy:Medium:Hard
  final String focusStrategy;
  final List<String> sections;

  const ChapterConfig({
    required this.chapterName,
    required this.importance,
    required this.suggestedQuestions,
    required this.percentage,
    required this.difficultyDistribution,
    required this.focusStrategy,
    required this.sections,
  });

  /// 从 JSON 创建
  factory ChapterConfig.fromJson(Map<String, dynamic> json) {
    return ChapterConfig(
      chapterName: json['chapterName'] as String,
      importance: json['importance'] as String,
      suggestedQuestions: json['suggestedQuestions'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      difficultyDistribution: Map<String, double>.from(
        (json['difficultyDistribution'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      focusStrategy: json['focusStrategy'] as String,
      sections: List<String>.from(json['sections'] as List),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'chapterName': chapterName,
      'importance': importance,
      'suggestedQuestions': suggestedQuestions,
      'percentage': percentage,
      'difficultyDistribution': difficultyDistribution,
      'focusStrategy': focusStrategy,
      'sections': sections,
    };
  }
}

/// 所有学习主题的配置
class ThemeConfigs {
  // 高中衔接大学数学基础 (490题)
  static final ThemeConfig highSchoolToCollege = ThemeConfig(
    name: '高中衔接大学数学基础',
    icon: '🏫',
    totalQuestions: 490,
    difficultyDistribution: {
      'Easy': 0.25,    // 25% ≈ 123题
      'Medium': 0.55,  // 55% ≈ 270题
      'Hard': 0.20,    // 20% ≈ 97题
    },
    chapters: [
      ChapterConfig(
        chapterName: '第1章 三角函数',
        importance: '最高',
        suggestedQuestions: 110,
        percentage: 22.4,
        difficultyDistribution: {
          'Easy': 0.25,
          'Medium': 0.55,
          'Hard': 0.20,
        },
        focusStrategy: '高权重维持。确保 §1.2 和 §1.3 公式的高效运用。',
        sections: [
          '§1.1 三角函数的概念',
          '§1.2 两角和与差的三角函数',
          '§1.3 三角函数的积化和差与和差化积',
        ],
      ),
      ChapterConfig(
        chapterName: '第2章 代数与方程',
        importance: '基础',
        suggestedQuestions: 50,
        percentage: 10.2,
        difficultyDistribution: {
          'Easy': 0.40,
          'Medium': 0.50,
          'Hard': 0.10,
        },
        focusStrategy: '重点巩固 §2.3 解方程的能力。',
        sections: [
          '§2.1 代数式及其运算',
          '§2.2 一元二次方程的性质',
          '§2.3 解一元代数方程',
        ],
      ),
      ChapterConfig(
        chapterName: '第3章 平面几何',
        importance: '低',
        suggestedQuestions: 30,
        percentage: 6.1,
        difficultyDistribution: {
          'Easy': 0.50,
          'Medium': 0.45,
          'Hard': 0.05,
        },
        focusStrategy: '基础回顾，重点在 §3.4 相似形。',
        sections: [
          '§3.1 三角形',
          '§3.2 四边形',
          '§3.3 圆',
          '§3.4 相似形',
        ],
      ),
      ChapterConfig(
        chapterName: '第4章 反三角函数',
        importance: '高',
        suggestedQuestions: 70,
        percentage: 14.3,
        difficultyDistribution: {
          'Easy': 0.20,
          'Medium': 0.60,
          'Hard': 0.20,
        },
        focusStrategy: '重点放在 §4.2 性质和 §4.3 三角方程的求解。',
        sections: [
          '§4.1 反函数',
          '§4.2 反三角函数',
          '§4.3 三角方程',
        ],
      ),
      ChapterConfig(
        chapterName: '第5章 排列与组合',
        importance: '极高',
        suggestedQuestions: 100,
        percentage: 20.4,
        difficultyDistribution: {
          'Easy': 0.20,
          'Medium': 0.60,
          'Hard': 0.20,
        },
        focusStrategy: '维持最高权重之一。侧重 §5.1-§5.3 计数和 §5.5 数学归纳法。',
        sections: [
          '§5.1 分类计数原理与分步计数原理',
          '§5.2 排列',
          '§5.3 组合',
          '§5.4 二项式定理',
          '§5.5 数学归纳法',
        ],
      ),
      ChapterConfig(
        chapterName: '第6章 复数',
        importance: '高',
        suggestedQuestions: 60,
        percentage: 12.2,
        difficultyDistribution: {
          'Easy': 0.30,
          'Medium': 0.50,
          'Hard': 0.20,
        },
        focusStrategy: '中等权重。侧重 §6.4 和 §6.5 中复数的几何意义和指数形式运算。',
        sections: [
          '§6.1 复数的概念',
          '§6.2 复数的运算',
          '§6.3 数系的扩充',
          '§6.4 复数与平面向量、三角函数的联系',
          '§6.5 复数的指数形式',
        ],
      ),
      ChapterConfig(
        chapterName: '第7章 参数方程与极坐标方程',
        importance: '高',
        suggestedQuestions: 70,
        percentage: 14.3,
        difficultyDistribution: {
          'Easy': 0.20,
          'Medium': 0.60,
          'Hard': 0.20,
        },
        focusStrategy: '重点强化 §7.1 和 §7.2 坐标系转换能力。',
        sections: [
          '§7.1 参数方程',
          '§7.2 极坐标方程',
        ],
      ),
    ],
  );

  // 专升本 (待定义具体章节和分配)
  static final ThemeConfig collegeDegree = ThemeConfig(
    name: '专升本',
    icon: '📈',
    totalQuestions: 400,
    difficultyDistribution: {
      'Easy': 0.20,
      'Medium': 0.60,
      'Hard': 0.20,
    },
    chapters: [
      ChapterConfig(
        chapterName: '高等数学',
        importance: '极高',
        suggestedQuestions: 200,
        percentage: 50.0,
        difficultyDistribution: {
          'Easy': 0.20,
          'Medium': 0.60,
          'Hard': 0.20,
        },
        focusStrategy: '核心内容，包括微积分基础。',
        sections: ['极限', '导数', '积分', '微分方程'],
      ),
      ChapterConfig(
        chapterName: '线性代数',
        importance: '高',
        suggestedQuestions: 120,
        percentage: 30.0,
        difficultyDistribution: {
          'Easy': 0.25,
          'Medium': 0.55,
          'Hard': 0.20,
        },
        focusStrategy: '矩阵运算和线性方程组。',
        sections: ['矩阵', '行列式', '线性方程组', '特征值'],
      ),
      ChapterConfig(
        chapterName: '概率论',
        importance: '高',
        suggestedQuestions: 80,
        percentage: 20.0,
        difficultyDistribution: {
          'Easy': 0.30,
          'Medium': 0.50,
          'Hard': 0.20,
        },
        focusStrategy: '概率计算和分布函数。',
        sections: ['概率基础', '随机变量', '概率分布'],
      ),
    ],
  );

  // 高数期末考试
  static final ThemeConfig calcExam = ThemeConfig(
    name: '高数期末考试',
    icon: '📋',
    totalQuestions: 300,
    difficultyDistribution: {
      'Easy': 0.30,
      'Medium': 0.50,
      'Hard': 0.20,
    },
    chapters: [
      ChapterConfig(
        chapterName: '极限与连续',
        importance: '高',
        suggestedQuestions: 80,
        percentage: 26.7,
        difficultyDistribution: {
          'Easy': 0.35,
          'Medium': 0.45,
          'Hard': 0.20,
        },
        focusStrategy: '基础但重要，掌握极限计算技巧。',
        sections: ['数列极限', '函数极限', '连续性'],
      ),
      ChapterConfig(
        chapterName: '导数与微分',
        importance: '极高',
        suggestedQuestions: 90,
        percentage: 30.0,
        difficultyDistribution: {
          'Easy': 0.25,
          'Medium': 0.55,
          'Hard': 0.20,
        },
        focusStrategy: '核心内容，导数计算和应用。',
        sections: ['导数定义', '导数计算', '微分', '导数应用'],
      ),
      ChapterConfig(
        chapterName: '积分',
        importance: '极高',
        suggestedQuestions: 90,
        percentage: 30.0,
        difficultyDistribution: {
          'Easy': 0.25,
          'Medium': 0.55,
          'Hard': 0.20,
        },
        focusStrategy: '重点掌握不定积分和定积分计算。',
        sections: ['不定积分', '定积分', '积分应用'],
      ),
      ChapterConfig(
        chapterName: '微分方程',
        importance: '高',
        suggestedQuestions: 40,
        percentage: 13.3,
        difficultyDistribution: {
          'Easy': 0.30,
          'Medium': 0.50,
          'Hard': 0.20,
        },
        focusStrategy: '基本类型微分方程的求解。',
        sections: ['一阶微分方程', '二阶微分方程'],
      ),
    ],
  );

  /// 根据主题名称获取配置
  static ThemeConfig? getConfig(String themeName) {
    switch (themeName) {
      case '高中衔接大学数学基础':
        return highSchoolToCollege;
      case '专升本':
        return collegeDegree;
      case '高数期末考试':
        return calcExam;
      default:
        return null;
    }
  }

  /// 获取所有主题配置
  static List<ThemeConfig> getAllConfigs() {
    return [highSchoolToCollege, collegeDegree, calcExam];
  }
}

