import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = "AIzaSyBFJDZ-Fwyuw1ZR0AFx98VZpGZtXI0V9mA"; // substitua pela sua
  final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  /// Envia a mensagem do usuário para o Gemini, limitando a IA a assuntos financeiros
  Future<String> sendMessage(String userText) async {
    // Prompt que restringe a IA a finanças
    final prompt = """
Você é um consultor financeiro. Responda apenas sobre finanças pessoais, gastos, receitas, orçamento e investimentos.
Não fale sobre nada que não seja relacionado a finanças.
Usuário disse: "$userText"
""";

    final response = await http.post(
      Uri.parse("$baseUrl?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
          "Não entendi sua pergunta.";
    } else {
      throw Exception("Erro do Gemini: ${response.body}");
    }
  }
}
