import 'package:flutter/material.dart';
import '../../drill/views/drill_page.dart';
import '../../tutorial/views/tutorial_page.dart';
import '../../recommendation/views/recommendation_page.dart';
import '../../profile/views/profile_page.dart';
import '../../settings/views/settings_page.dart';
import '../../../widgets/bottom_nav_bar.dart';

/// 主页面 - 包含底部导航
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DrillPage(),
    TutorialPage(),
    RecommendationPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
