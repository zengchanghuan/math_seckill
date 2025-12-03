import 'package:flutter/material.dart';

/// 底部导航栏
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: '刷题',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: '讲解',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb),
          label: '智能推荐',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: '学习画像',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }
}
