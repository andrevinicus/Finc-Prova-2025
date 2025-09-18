import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBarWidget({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 3,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(195, 22, 22, 22),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: Offset(-22, 0),
              child: Icon(CupertinoIcons.graph_square),
            ),
            activeIcon: Transform.translate(
              offset: Offset(-22, 0),
              child: Icon(CupertinoIcons.graph_square_fill, size: 26),
            ),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: Offset(22, 0),
              child: Icon(CupertinoIcons.flag),
            ),
            activeIcon: Transform.translate(
              offset: Offset(22, 0),
              child: Icon(CupertinoIcons.flag_fill, size: 26),
            ),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble, size: 26),
            label: 'Assistente',
          ),
        ],
      ),
    );
  }
}