import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message_entity.dart';

abstract class ChatRepository {
  Future<void> saveMessage(String userId, String chatId, ChatMessageEntity message);
  Future<List<ChatMessageEntity>> getMessages(String userId, String chatId);
  Future<List<String>> getUserChats(String userId);
}

class FirebaseChatRepository implements ChatRepository {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  /// Retorna todos os chatIds de um usuário
  @override
Future<List<String>> getUserChats(String userId) async {
  print('FIRE: Buscando chats do usuário $userId');
  final snapshot = await usersCollection.doc(userId).collection('chatHistory').get();
  
  print('FIRE: Docs encontrados: ${snapshot.docs.length}');
  for (var doc in snapshot.docs) {
    print('FIRE: Doc ID = ${doc.id}');
  }
  
  return snapshot.docs.map((doc) => doc.id).toList();
}

  /// Salva uma mensagem garantindo que o chat existe
  @override
  Future<void> saveMessage(String userId, String chatId, ChatMessageEntity message) async {
    try {
      final chatDocRef = usersCollection
          .doc(userId)
          .collection('chatHistory')
          .doc(chatId);

      // Cria o chat se não existir
      final chatSnapshot = await chatDocRef.get();
      if (!chatSnapshot.exists) {
        await chatDocRef.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ FIRE: Chat $chatId criado para o usuário $userId');
      }

      // Adiciona a mensagem na subcoleção messages
      await chatDocRef.collection('messages').add(message.toDocument());

      print('💬 FIRE: Mensagem salva para $userId no chat $chatId: ${message.text}');
    } catch (e, st) {
      print('❌ FIRE: Erro ao salvar mensagem para $userId no chat $chatId: $e\n$st');
      throw Exception('Erro ao salvar mensagem');
    }
  }

  /// Retorna todas as mensagens de um chat
  @override
  Future<List<ChatMessageEntity>> getMessages(String userId, String chatId) async {
    try {
      print('🔥 FIRE: Buscando mensagens do chat $chatId para o usuário $userId');
      final snapshot = await usersCollection
          .doc(userId)
          .collection('chatHistory')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      if (snapshot.docs.isEmpty) {
        print('📄 FIRE: Nenhuma mensagem encontrada para $userId no chat $chatId');
        return [];
      }

      final messages = <ChatMessageEntity>[];
      for (var doc in snapshot.docs) {
        try {
          final message = ChatMessageEntity.fromDocument(doc.data());
          messages.add(message);
          print('✅ FIRE: Mensagem carregada: ${message.sender} - ${message.text}');
        } catch (e, st) {
          print('❌ FIRE: Falha ao parsear documento ${doc.id}: $e\n$st');
        }
      }

      print('📄 FIRE: Total de mensagens carregadas para $userId no chat $chatId: ${messages.length}');
      return messages;
    } catch (e, st) {
      print('❌ FIRE: Erro ao buscar mensagens para $userId no chat $chatId: $e\n$st');
      throw Exception('Erro ao buscar mensagens');
    }
  }
}
