import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String baseUrl = dotenv.env['GEMINI_BASE_URL'] ?? '';

  /// Envia a mensagem do usuário para o modelo Gemini e retorna a resposta de texto.
  Future<String> sendMessage(String promptExterno) async {
    if (apiKey.isEmpty || baseUrl.isEmpty) {
      throw Exception('GEMINI_API_KEY ou GEMINI_BASE_URL não configurados no .env');
    }

    developer.log(
      '[GEMINI][REQUEST] Prompt enviado (${promptExterno.length} chars):\n$promptExterno',
      name: 'GeminiService',
    );

    try {
      final uri = Uri.parse('$baseUrl?key=$apiKey');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": promptExterno}
              ]
            }
          ]
        }),
      );

      developer.log('[GEMINI][STATUS] ${response.statusCode}', name: 'GeminiService');
      developer.log('[GEMINI][RAW RESPONSE]\n${response.body}', name: 'GeminiService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extrai o texto de resposta (caso exista)
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        if (text == null || text.trim().isEmpty) {
          return "O modelo não retornou nenhuma resposta compreensível.";
        }

        developer.log('[GEMINI][RESPONSE]\n$text', name: 'GeminiService');
        return text.trim();
      } else {
        developer.log(
          '[GEMINI][ERROR ${response.statusCode}] ${response.body}',
          name: 'GeminiService',
        );

        throw Exception(
          'Erro ${response.statusCode} ao se comunicar com Gemini:\n${response.body}',
        );
      }
    } catch (e, stack) {
      developer.log('[GEMINI][EXCEPTION] $e', name: 'GeminiService', error: e, stackTrace: stack);
      return 'Ocorreu um erro ao gerar a resposta: $e';
    }
  }
}
