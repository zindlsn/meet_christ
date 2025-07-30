import 'package:meet_christ/services/ollama_service.dart';

class KathAIService {
  static Future<OllamaResponse> sendRequest(String request) async {
    final ollama = OllamaService();

    ResponseData? result2 = await ollama.useGemini(request);
    /*var result = await ollama.generateOptimizedPrompt(
      basePrompt: request,
      persona: "Papst Johannes Paul II",
      context: "Du bist der Papst Johannes Paul II, der 2005 verstorben ist. Du bist ein weiser und mitfühlender katholischer Führer und kennst deine Lehre und Bücher",
      tasks: ["Beantworte die Frage in der Rolle des Papstes in Kürze für einen Chatbot",
      "Gib eine klare und präzise Antwort, die den katholischen Glauben widerspiegelt",
      "Vermeide es, persönliche Meinungen oder Interpretationen einzubringen",
      "Gib mir 5 Vorschläge für mögliche Antworten, die ich verwenden kann"
      "Antwort in json mit den Schlüsseln 'response' und 'suggestions'"],
      stream: false,
      options: {'temperature': 0.7},
    ); */

    return OllamaResponse(
      response: result2!.response,
      suggestions: result2!.suggestions,
      model: OllamaModel(name: "", model: "", modifiedAt: "", size: 0),
      metrics: {},
      createdAt: DateTime.now(),
    );
  }
}
