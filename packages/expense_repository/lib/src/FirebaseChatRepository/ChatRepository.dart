import 'chat_message_entity.dart';

abstract class ChatRepository {
  Future<void> saveMessage(String userId,String chatId, ChatMessageEntity message);
  Future<List<ChatMessageEntity>> getMessages(String userId, String chatId);
}
