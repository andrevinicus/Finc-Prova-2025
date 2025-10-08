import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey =
      "AIzaSyBmIuBJrRHuOVCeF6cAioynweUT6gpa1dI"; // substitua pela sua
  final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

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
