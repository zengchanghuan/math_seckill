import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/problem_service_v2.dart';
import 'features/drill/views/drill_page.dart';
import 'features/formulas/views/formula_list_page.dart';
import 'features/profile/views/profile_page.dart';
import 'features/answer/views/answer_page.dart';
import 'features/onboarding/views/theme_selection_page.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载设置（快速，不阻塞）
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  final themeSelected = prefs.getBool('theme_selected') ?? false;

  // 先启动应用，服务延迟初始化
  runApp(MyApp(
    isDarkMode: isDarkMode,
    showThemeSelection: !themeSelected,
  ));

  // 在后台初始化服务（不阻塞UI）
  Get.put(ProblemServiceV2(), permanent: true);
  // FormulaService暂时不需要（公式库待开发）
  // Get.put(FormulaService(), permanent: true);
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  final bool showThemeSelection;

  const MyApp({
    super.key,
    required this.isDarkMode,
    this.showThemeSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '微积分刷题',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: showThemeSelection ? const ThemeSelectionPage() : const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DrillPage(),
    AnswerPage(),
    FormulaListPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
