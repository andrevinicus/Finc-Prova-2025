import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String baseUrl = dotenv.env['GEMINI_BASE_URL'] ?? '';

  /// Envia a mensagem do usuário para o Gemini, limitando a IA a assuntos financeiros
  Future<String> sendMessage(String prompt) async {
    developer.log(
      '[GEMINI][REQUEST] Enviando prompt para Gemini: $prompt',
      name: 'GeminiService',
    );

    try {
      final response = await http.post(
        Uri.parse("$baseUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      developer.log(
        '[GEMINI][HTTP STATUS] ${response.statusCode}',
        name: 'GeminiService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "Não entendi sua pergunta.";
        developer.log('[GEMINI][RESPONSE] $text', name: 'GeminiService');
        return text;
      } else {
        developer.log(
          '[GEMINI][ERROR] Status ${response.statusCode}: ${response.body}',
          name: 'GeminiService',
        );
        throw Exception("Erro do Gemini: ${response.body}");
      }
    } catch (e) {
      developer.log('[GEMINI][EXCEPTION] $e', name: 'GeminiService');
      rethrow;
    }
  }
}
