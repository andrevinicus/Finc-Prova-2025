import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String avatarUrl;
  final String authorName;
  final String timeAgo;
  final String? title;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;

  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.authorName,
    required this.timeAgo,
    this.title,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cabeçalho com avatar e nome
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                )
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Título (se existir)
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),

            const SizedBox(height: 6),

            // 🔹 Conteúdo
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 10),

            // 🔹 Imagem (se existir)
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              ),

            const SizedBox(height: 12),

            // 🔹 Barra de interação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAction(Icons.thumb_up_alt_outlined, '$likes'),
                _buildAction(Icons.chat_bubble_outline, '$comments'),
                _buildAction(Icons.share_outlined, '$shares'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
