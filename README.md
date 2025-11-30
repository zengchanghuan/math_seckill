# 微积分刷题 App

一个基于 Flutter 开发的微积分学习应用，提供题目练习、公式查阅和个人学习统计功能。

## 📱 项目简介

这是一个专为微积分学习设计的移动应用，采用三标签（Tab）结构，帮助用户通过刷题、查阅公式和跟踪学习进度来提升微积分能力。

## ✨ 功能特性

### 📚 Tab 1: 刷题 (Drill)
- **卡片式滑动界面**：流畅的左右滑动切换题目
- **主题/难度筛选**：支持按主题（导数基础、极限与连续、积分等）和难度（基础、进阶）筛选题目
- **答案检查**：输入答案后实时检查正确性
- **解答查看**：查看详细的解题步骤和解答过程
- **进度跟踪**：实时显示答题进度（已完成/总题数）
- **错题记录**：自动记录做错的题目到错题本

### 📖 Tab 2: 公式 (Formulas)
- **分类浏览**：按类别查看公式（极限与连续、导数、积分、级数）
- **搜索功能**：快速搜索公式名称、描述或分类
- **公式详情**：查看公式的详细说明和应用示例
- **收藏功能**：收藏常用公式，方便快速查阅

### 👤 Tab 3: 个人 (Profile)
- **学习统计**：
  - 总答题数、正确数、错误数
  - 正确率统计
  - 最强/最弱主题分析
- **错题本**：查看所有做错的题目，支持再次练习
- **收藏夹**：管理收藏的公式
- **设置功能**：
  - 深色模式切换
  - 字体大小调整
- **关于我**：开发者信息和技术栈介绍

## 🛠 技术栈

- **框架**：Flutter 3.10.3
- **状态管理**：GetX 4.6.5
- **本地存储**：SharedPreferences 2.2.2
- **LaTeX 渲染**：自定义 MathText 组件（兼容 Flutter 3.10）
- **开发语言**：Dart 3.0.3

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/
│   ├── models/                 # 数据模型
│   │   ├── problem.dart        # 题目模型
│   │   ├── formula.dart        # 公式模型
│   │   └── user_stats.dart     # 用户统计模型
│   └── services/               # 服务层
│       ├── problem_service.dart # 题目数据服务
│       └── formula_service.dart # 公式数据服务
├── features/
│   ├── drill/                  # 刷题功能
│   │   ├── controllers/
│   │   │   └── drill_controller.dart
│   │   ├── views/
│   │   │   └── drill_page.dart
│   │   └── widgets/
│   │       ├── problem_card.dart
│   │       ├── topic_selector.dart
│   │       └── progress_bar.dart
│   ├── formulas/               # 公式功能
│   │   ├── controllers/
│   │   │   └── formula_controller.dart
│   │   ├── views/
│   │   │   ├── formula_list_page.dart
│   │   │   └── formula_detail_page.dart
│   │   └── widgets/
│   │       ├── formula_card.dart
│   │       └── search_bar.dart
│   └── profile/                # 个人功能
│       ├── controllers/
│       │   └── profile_controller.dart
│       ├── views/
│       │   └── profile_page.dart
│       └── widgets/
│           ├── stats_card.dart
│           ├── wrong_problems_page.dart
│           └── favorites_page.dart
└── widgets/
    ├── bottom_nav_bar.dart     # 底部导航栏
    └── math_text.dart          # LaTeX 文本显示组件

assets/
└── data/
    ├── problems.json           # 题目数据
    └── formulas.json           # 公式数据
```

## 🚀 安装和运行

### 环境要求

- Flutter SDK >= 3.0.3
- Dart SDK >= 3.0.3
- iOS 12.0+ (iOS 开发)
- Android API 21+ (Android 开发)

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone git@github.com:zengchanghuan/math_seckill.git
   cd math_seckill
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **iOS 依赖安装**（仅 iOS 开发需要）
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **运行应用**
   ```bash
   # 运行在连接的设备或模拟器上
   flutter run
   
   # 或指定平台
   flutter run -d ios
   flutter run -d android
   ```

### 构建发布版本

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

## 📊 数据说明

### 题目数据 (problems.json)
- 包含 10 道示例微积分题目
- 涵盖主题：导数基础、极限与连续、积分
- 难度等级：基础、进阶
- 每道题目包含：问题、答案、详细解答

### 公式数据 (formulas.json)
- 包含 18 个微积分核心公式
- 分类：极限与连续、导数、积分、级数
- 每个公式包含：名称、公式、描述、应用示例

## 🎯 使用说明

### 刷题功能
1. 在"刷题"标签页选择主题和难度
2. 左右滑动卡片查看不同题目
3. 在输入框中输入答案
4. 点击"检查"按钮验证答案
5. 查看解答了解详细步骤
6. 点击"下一题"继续练习

### 公式查阅
1. 在"公式"标签页浏览公式分类
2. 使用搜索框快速查找公式
3. 点击公式卡片查看详细信息
4. 点击心形图标收藏常用公式

### 学习统计
1. 在"我"标签页查看学习统计
2. 查看总答题数、正确率等数据
3. 访问错题本复习做错的题目
4. 在收藏夹中查看收藏的公式
5. 在设置中调整主题和字体大小

## 🔧 开发说明

### 状态管理
使用 GetX 进行状态管理：
- `DrillController`：管理刷题相关状态
- `FormulaController`：管理公式相关状态
- `ProfileController`：管理个人相关状态

### 数据持久化
使用 SharedPreferences 存储：
- 用户答题记录和统计
- 错题本
- 收藏的公式
- 用户设置（主题、字体大小）

### LaTeX 渲染
由于 Flutter 3.10.3 的限制，使用自定义 `MathText` 组件：
- 将常见 LaTeX 符号转换为 Unicode
- 简化分数显示
- 支持可选择的文本显示

**注意**：如需更好的 LaTeX 渲染效果，建议升级 Flutter SDK 到 3.13+ 并使用 `flutter_math_fork` 或 `flutter_tex` 库。

## 📝 开发者信息

- **开发者**：zengchanghuan
- **技术栈**：Flutter, SwiftUI, Objective-C, Swift
- **开发目标**：成为机器学习 AI 工程师
- **当前学习**：线性代数、概率与统计

## 🐛 已知问题

1. Metal Toolchain 警告：Xcode 中可能出现 Metal toolchain 搜索路径警告，这是系统级别的警告，不影响构建和运行。
2. LaTeX 渲染：当前使用简化的文本显示，如需更好的数学公式渲染，建议升级 Flutter SDK。

## 🔮 未来计划

- [ ] 升级 Flutter SDK 以支持更好的 LaTeX 渲染
- [ ] 扩展题库，添加更多题目和公式
- [ ] 添加题目收藏功能
- [ ] 实现学习计划和每日练习提醒
- [ ] 添加动画效果和 UI 优化
- [ ] 实现题目懒加载和性能优化

## 📄 许可证

本项目为个人学习项目。

## 🙏 致谢

感谢 Flutter 社区和所有开源贡献者。

---

**最后更新**：2024年11月30日
