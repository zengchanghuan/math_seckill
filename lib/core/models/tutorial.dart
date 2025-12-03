/// 知识卡片模型
class KnowledgeCard {
  final String title;
  final String summary;
  final String formula;
  
  KnowledgeCard({
    required this.title,
    required this.summary,
    required this.formula,
  });
  
  factory KnowledgeCard.fromJson(Map<String, dynamic> json) {
    return KnowledgeCard(
      title: json['title'] as String,
      summary: json['summary'] as String,
      formula: json['formula'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'formula': formula,
    };
  }
}

/// 小节讲解模型
class TutorialSection {
  final String sectionName;
  final List<KnowledgeCard> knowledgeCards;
  
  TutorialSection({
    required this.sectionName,
    required this.knowledgeCards,
  });
  
  factory TutorialSection.fromJson(Map<String, dynamic> json) {
    return TutorialSection(
      sectionName: json['sectionName'] as String,
      knowledgeCards: (json['knowledgeCards'] as List)
          .map((card) => KnowledgeCard.fromJson(card as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'knowledgeCards': knowledgeCards.map((card) => card.toJson()).toList(),
    };
  }
}

/// 章节讲解模型
class TutorialChapter {
  final String chapterName;
  final List<TutorialSection> sections;
  
  TutorialChapter({
    required this.chapterName,
    required this.sections,
  });
  
  factory TutorialChapter.fromJson(Map<String, dynamic> json) {
    return TutorialChapter(
      chapterName: json['chapterName'] as String,
      sections: (json['sections'] as List)
          .map((section) => TutorialSection.fromJson(section as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'chapterName': chapterName,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
  
  /// 获取所有知识卡片
  List<KnowledgeCard> getAllCards() {
    return sections.expand((section) => section.knowledgeCards).toList();
  }
}

/// 主题讲解模型
class TutorialTheme {
  final String themeName;
  final List<TutorialChapter> chapters;
  
  TutorialTheme({
    required this.themeName,
    required this.chapters,
  });
  
  factory TutorialTheme.fromJson(Map<String, dynamic> json) {
    return TutorialTheme(
      themeName: json['themeName'] as String,
      chapters: (json['chapters'] as List)
          .map((chapter) => TutorialChapter.fromJson(chapter as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'themeName': themeName,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
  
  /// 根据章节名称获取章节
  TutorialChapter? getChapter(String chapterName) {
    try {
      return chapters.firstWhere((c) => c.chapterName == chapterName);
    } catch (e) {
      return null;
    }
  }
}

/// 讲解数据响应模型
class TutorialsResponse {
  final String version;
  final String lastUpdated;
  final List<TutorialTheme> themes;
  
  TutorialsResponse({
    required this.version,
    required this.lastUpdated,
    required this.themes,
  });
  
  factory TutorialsResponse.fromJson(Map<String, dynamic> json) {
    return TutorialsResponse(
      version: json['version'] as String,
      lastUpdated: json['lastUpdated'] as String,
      themes: (json['themes'] as List)
          .map((theme) => TutorialTheme.fromJson(theme as Map<String, dynamic>))
          .toList(),
    );
  }
  
  /// 根据主题名称获取主题
  TutorialTheme? getTheme(String themeName) {
    try {
      return themes.firstWhere((t) => t.themeName == themeName);
    } catch (e) {
      return null;
    }
  }
}

