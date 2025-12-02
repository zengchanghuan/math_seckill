/// 主题的章节和节结构定义
class TopicStructure {
  final String topic;
  final List<Chapter> chapters;

  const TopicStructure({
    required this.topic,
    required this.chapters,
  });
}

class Chapter {
  final String name; // 例如 "第1章 三角函数"
  final List<Section> sections;

  const Chapter({
    required this.name,
    required this.sections,
  });
}

class Section {
  final String name; // 例如 "§1.1 三角函数的概念"

  const Section({
    required this.name,
  });
}

/// "高中衔接大学数学基础"的章节结构
const TopicStructure highSchoolToUniversityStructure = TopicStructure(
  topic: '高中衔接大学数学基础',
  chapters: [
    Chapter(
      name: '第1章 三角函数',
      sections: [
        Section(name: '§1.1 三角函数的概念'),
        Section(name: '§1.2 两角和与差的三角函数'),
        Section(name: '§1.3 三角函数的积化和差与和差化积'),
      ],
    ),
    Chapter(
      name: '第2章 代数与方程',
      sections: [
        Section(name: '§2.1 代数式及其运算'),
        Section(name: '§2.2 一元二次方程的性质'),
        Section(name: '§2.3 解一元代数方程'),
      ],
    ),
    Chapter(
      name: '第3章 平面几何',
      sections: [
        Section(name: '§3.1 三角形'),
        Section(name: '§3.2 四边形'),
        Section(name: '§3.3 圆'),
        Section(name: '§3.4 相似形'),
      ],
    ),
    Chapter(
      name: '第4章 反三角函数',
      sections: [
        Section(name: '§4.1 反函数'),
        Section(name: '§4.2 反三角函数'),
        Section(name: '§4.3 三角方程'),
      ],
    ),
    Chapter(
      name: '第5章 排列与组合',
      sections: [
        Section(name: '§5.1 分类计数原理与分步计数原理'),
        Section(name: '§5.2 排列'),
        Section(name: '§5.3 组合'),
        Section(name: '§5.4 二项式定理'),
        Section(name: '§5.5 数学归纳法'),
      ],
    ),
    Chapter(
      name: '第6章 复数',
      sections: [
        Section(name: '§6.1 复数的概念'),
        Section(name: '§6.2 复数的运算'),
        Section(name: '§6.3 数系的扩充'),
        Section(name: '§6.4 复数与平面向量、三角函数的联系'),
        Section(name: '§6.5 复数的指数形式'),
      ],
    ),
    Chapter(
      name: '第7章 参数方程与极坐标方程',
      sections: [
        Section(name: '§7.1 参数方程'),
        Section(name: '§7.2 极坐标方程'),
      ],
    ),
  ],
);

/// 获取主题的章节结构
TopicStructure? getTopicStructure(String topic) {
  switch (topic) {
    case '高中衔接大学数学基础':
      return highSchoolToUniversityStructure;
    default:
      return null;
  }
}


