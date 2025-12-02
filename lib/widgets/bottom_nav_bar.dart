import 'package:flutter/material.dart';

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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: '刷题',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: '解答',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.functions),
          label: '公式',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我',
        ),
      ],
    );
  }
}
