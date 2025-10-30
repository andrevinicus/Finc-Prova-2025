import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalheGrupoScreen extends StatelessWidget {
  final String grupoId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DetalheGrupoScreen({required this.grupoId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Grupo'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('grupos').doc(grupoId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var grupo = snapshot.data!;
          var membros = List.from(grupo['membros'] ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info do grupo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(grupo['nome'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(grupo['descricao']),
                      const SizedBox(height: 8),
                      Text('Progresso coletivo: ${grupo['progressoColetivo'] ?? 0}%'),
                    ],
                  ),
                ),
                const Divider(),

                // Lista de membros
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Membros', style: Theme.of(context).textTheme.titleMedium),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: membros.length,
                  itemBuilder: (context, index) {
                    var membro = membros[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(membro['nome'] ?? 'Usuário'),
                      subtitle: Text('Progresso: ${membro['progresso'] ?? 0}%'),
                    );
                  },
                ),

                const Divider(),

                // Feed do grupo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Feed', style: Theme.of(context).textTheme.titleMedium),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('grupos').doc(grupoId).collection('posts').orderBy('data', descending: true).snapshots(),
                  builder: (context, postSnapshot) {
                    if (!postSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                    var posts = postSnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post = posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(post['autorNome']),
                            subtitle: Text(post['conteudo']),
                            trailing: Text('${post['curtidas'] ?? 0} 👍'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_comment),
        onPressed: () {
          // Adicionar post
          _adicionarPost(context);
        },
      ),
    );
  }

  void _adicionarPost(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Post'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Escreva sua mensagem'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _firestore.collection('grupos').doc(grupoId).collection('posts').add({
                  'conteudo': controller.text,
                  'autorNome': 'Usuário Exemplo', // aqui você pega o nome do usuário logado
                  'data': Timestamp.now(),
                  'curtidas': 0,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Postar'),
          ),
        ],
      ),
    );
  }
}
