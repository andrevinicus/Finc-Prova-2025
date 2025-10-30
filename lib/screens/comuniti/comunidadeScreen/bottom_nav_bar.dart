import 'package:finc/screens/comuniti/comunidadeScreen/fin_community_feed_screen.dart';
import 'package:finc/screens/comuniti/criargrupo_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';



class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    this.currentIndex = 0,
    required this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinCommunityFeedScreen()),
        );
        break;
      case 3: // Perfil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
      default:
        onTap(index); // Demais abas apenas atualizam índice
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(
            icon: Icons.home,
            label: 'Feed',
            active: currentIndex == 0,
            activeColor: const Color(0xFFD4AF37),
            onTap: () => _handleTap(context, 0),
          ),
          BottomNavItem(
            icon: Icons.pie_chart,
            label: 'Portfolio',
            active: currentIndex == 1,
            onTap: () => _handleTap(context, 1),
          ),
          BottomNavItem(
            icon: Icons.groups,
            label: 'Comunidade',
            active: currentIndex == 2,
            onTap: () => _handleTap(context, 2),
          ),
          BottomNavItem(
            icon: Icons.person,
            label: 'Perfil',
            active: currentIndex == 3,
            activeColor: const Color(0xFFD4AF37),
            onTap: () => _handleTap(context, 3),
          ),
        ],
      ),
    );
  }
}
