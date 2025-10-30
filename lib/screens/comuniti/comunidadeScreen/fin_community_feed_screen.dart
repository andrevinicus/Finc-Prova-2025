import 'package:finc/screens/comuniti/criargrupo_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'filter_chip_custom.dart';
import 'post_card.dart';
import 'story_item.dart';

class FinCommunityFeedScreen extends StatefulWidget {
  const FinCommunityFeedScreen({Key? key}) : super(key: key);

  @override
  State<FinCommunityFeedScreen> createState() => _FinCommunityFeedScreenState();
}

class _FinCommunityFeedScreenState extends State<FinCommunityFeedScreen> {
  static const Color primaryColor = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFFDFDFD);
  static const Color textLight = Color(0xFF1E1E1E);
  static const Color subtleLight = Color(0xFFE0E0E0);

  static const String sampleAvatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuA8k3UbToW84CQNHzebUM9sL90myUBGKruIDLw7oETgEI3OGdVY34ay-XE1WAtmNEE4M0GGqZpypZ0X0l53_qxPU9kZlCBEtOBnPkeazo9grA4ZFtgyalOqcVZIID_lxzsLa6K7QAmL_YgdVdMZrcP84kLSRE1Ee3I3iI99tA0Amz3l49V4W5LcXcRIZLyT5lmlOV6AIbxWuzDBwI6m0Cz0ObL0p3Q7WuU0jlQY0HRIXagL48xkof_nNYyUOjwSQm_TjLUmP3MsLao';
  static const String samplePostImage = 'https://lh3.googleusercontent.com/aida-public/AB6AXuC54f_dH4TLbv9emguPJ-VF498nlnQr6OjIxjl7ApFy-vnCHZFbMcJgkFu86V1jdoXVg2RfUIbIWTcNQBKO3KhHRX0qQ5xRTxfz08chJU4Gti-Nd4q5E9cycKuL4Uhlgm5IlaH-aGH5UZV1KcISNml2H4sC3gCT0NAHpes1cAxhI7qp_hfjtzzOzbNzAycSD9uLklNSGzklBtNJqpJ1bh27TO9ZJSALrgzy0lmPLe85xSe_lV4Zgk_7s4UYegROx48Dr-jGwXmtHjo';

  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Icon(Icons.show_chart, color: primaryColor, size: 30),
        ),
        title: const Text(
          'FinCommunity',
          style: TextStyle(
            color: textLight,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: textLight),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Stories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: subtleLight, width: 0.5)),
            ),
            child: SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(width: 4),
                  StoryItem(label: 'Destaques', imageUrl: sampleAvatar, borderColor: primaryColor),
                  StoryItem(label: 'Novidades', imageUrl: sampleAvatar),
                  StoryItem(label: 'Análises', imageUrl: sampleAvatar),
                  StoryItem(label: 'Mercado', imageUrl: sampleAvatar),
                  StoryItem(label: 'Dicas', imageUrl: sampleAvatar),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: const [
                FilterChipCustom(label: 'Em alta', selected: true),
                SizedBox(width: 8),
                FilterChipCustom(label: 'Mais recentes'),
                SizedBox(width: 8),
                FilterChipCustom(label: 'Tópicos', showTrailingIcon: true),
                SizedBox(width: 8),
              ],
            ),
          ),
          // Posts
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: const [
                PostCard(
                  avatarUrl: sampleAvatar,
                  authorName: 'Maria Silva',
                  timeAgo: '2h atrás',
                  content: 'Minha opinião sobre o mercado e energias renováveis. Qual a sua aposta? #investimentos',
                  imageUrl: samplePostImage,
                  likes: 123,
                  comments: 45,
                  shares: 12,
                ),
                PostCard(
                  avatarUrl: sampleAvatar,
                  authorName: 'Carlos Pereira',
                  timeAgo: '5h atrás',
                  title: 'Diversificação de portfólio em 2024?',
                  content: 'Pensando em ETFs de mercados emergentes. O que acham?',
                  likes: 88,
                  comments: 21,
                  shares: 5,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
