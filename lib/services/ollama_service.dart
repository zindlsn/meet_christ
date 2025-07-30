import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

// https://medium.com/kbtg-life/integrating-llms-into-mobile-applications-using-gemini-and-flutter-a4640db03d88
class OllamaService {
  final String baseUrl;
  final String defaultModel;
  final Duration timeout;

  final String apiKey = "AIzaSyDQVY7_0y-T00enywLH3ivjdYJ2RgH2Zjw";

  // Constructor with default values
  OllamaService({
    this.baseUrl = 'http://localhost:11434',
    this.defaultModel = 'llama2',
    this.timeout = const Duration(seconds: 60),
  });

  Future<ResponseData?> useGemini2(PromptData data) async {
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // Prepare the prompt content
    final contents = [
      Content.text(
        'task: Return as json with keys "response" and 4 short followup words or sentences "suggestions" for the user to click on it',
      ),
      //  Content.text(request),
    ];

    try {
      // Call Gemini to generate content
      final GenerateContentResponse result = await model.generateContent(
        contents,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 100,
          topP: 0.95,
          topK: 40,
        ),
        tools: [
        ]
      );

      // The generated text should be a JSON string, so parse it
      final Map<String, dynamic> jsonMap = json.decode(
        extractJson(result.text!),
      );

      // Convert parsed JSON map to ResponseData object
      final responseData = ResponseData.fromJson(jsonMap);

      return responseData;
    } catch (e) {
      print("Error generating or parsing content: $e");
      return null;
    }
  }

  Future<ResponseData?> useGemini(String request) async {
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // Prepare the prompt content
    final contents = [
      Content.text(
        'task: Return as json with keys "response" and 4 short followup words or sentences "suggestions" for the user to click on it',
      ),
      Content.text(request),
    ];

    try {
      // Call Gemini to generate content
      final GenerateContentResponse result = await model.generateContent(
        contents,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 100,
          topP: 0.95,
          topK: 40,
        ),
        tools: [
        ]
      );

      // The generated text should be a JSON string, so parse it
      final Map<String, dynamic> jsonMap = json.decode(
        extractJson(result.text!),
      );

      // Convert parsed JSON map to ResponseData object
      final responseData = ResponseData.fromJson(jsonMap);

      return responseData;
    } catch (e) {
      print("Error generating or parsing content: $e");
      return null;
    }
  }

  String extractJson(String wrappedResponse) {
    // Remove starting ```
    String cleaned = wrappedResponse.replaceFirst(RegExp(r'^```json\s*'), '');
    // Remove ending ```
    cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');

    return cleaned.trim();
  }

  Future<OllamaResponse> generateOptimizedPrompt({
    required String basePrompt,
    String? persona,
    String? context,
    required List<String> tasks,
    String? format,
    String? examples,
    String? model,
    bool stream = false,
    Map<String, dynamic>? options,
  }) async {
    final fullPrompt = _buildOptimizedPrompt(
      basePrompt: basePrompt,
      persona: persona,
      context: context,
      tasks: tasks,
      format: format,
      examples: examples,
    );

    final uri = Uri.parse('$baseUrl/api/generate');
    final selectedModel = model ?? defaultModel;
    String requestBody = jsonEncode({
      'model': selectedModel,
      'prompt': fullPrompt,
      'stream': stream,
      'options': options ?? {},
    });
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': selectedModel,
              'prompt': fullPrompt,
              'stream': stream,
              'format': "json",
              'options': options,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return OllamaResponse.fromJson(jsonResponse);
      } else {
        throw OllamaApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } on TimeoutException {
      throw OllamaApiException(message: 'Request timed out');
    } catch (e) {
      throw OllamaApiException(message: 'Failed to generate text: $e');
    }
  }

  String _buildOptimizedPrompt({
    required String basePrompt,
    String? persona,
    String? context,
    required List<String> tasks,
    String? format,
    String? examples,
  }) {
    final buffer = StringBuffer();

    // 1. Persona
    if (persona != null) {
      buffer.writeln('You are $persona');
    }

    // 2. Context
    if (context != null) {
      buffer.writeln('Context: $context');
    }

    // 3. Task
    buffer.writeln('Task: ${tasks.join(', ')}');

    // 4. Format
    if (format != null) {
      buffer.writeln('Format your response as: $format');
    }

    // 5. Examples
    if (examples != null) {
      buffer.writeln('Examples of good responses:');
      buffer.writeln(examples);
    }

    // buffer.writeln('\nNow please respond to the following: $basePrompt');
    return buffer.toString();
  }
  // Generate text from prompt (single response)

  // Stream response version
  Stream<String> generateTextStream({
    required String prompt,
    String? model,
    Map<String, dynamic>? options,
  }) {
    final selectedModel = model ?? defaultModel;
    final uri = Uri.parse('$baseUrl/api/generate');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': selectedModel,
        'prompt': prompt,
        'stream': true,
        'options': options,
      });

    final streamController = StreamController<String>();
    final client = http.Client();

    client
        .send(request)
        .then((response) async {
          if (response.statusCode != 200) {
            streamController.addError(
              OllamaApiException(
                statusCode: response.statusCode,
                message: await response.stream.bytesToString(),
              ),
            );
            return;
          }

          await for (final chunk
              in response.stream
                  .transform(utf8.decoder)
                  .transform(const LineSplitter())) {
            if (chunk.isEmpty) continue;
            try {
              final json = jsonDecode(chunk);
              streamController.add(json['response'] as String);
            } catch (e) {
              streamController.addError(
                OllamaApiException(message: 'Error parsing response: $e'),
              );
            }
          }
          await streamController.close();
        })
        .catchError((e) {
          streamController.addError(
            OllamaApiException(message: 'Request failed: $e'),
          );
        });

    return streamController.stream;
  }

  Future<OllamaResponse> generateText({
    required String prompt,
    String? model,
    bool stream = false,
    Map<String, dynamic>? options,
  }) async {
    final uri = Uri.parse('$baseUrl/api/generate');
    final selectedModel = model ?? defaultModel;

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': selectedModel,
              'prompt': prompt,
              'stream': stream,
              'options': options,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return OllamaResponse.fromJson(jsonResponse);
      } else {
        throw OllamaApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } on TimeoutException {
      throw OllamaApiException(message: 'Request timed out');
    } catch (e) {
      throw OllamaApiException(message: 'Failed to generate text: $e');
    }
  }

  // List available models
  Future<List<OllamaModel>> listModels() async {
    final uri = Uri.parse('$baseUrl/api/tags');

    try {
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final models = jsonResponse['models'] as List;
        return models.map((m) => OllamaModel.fromJson(m)).toList();
      } else {
        throw OllamaApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } on TimeoutException {
      throw OllamaApiException(message: 'Request timed out');
    } catch (e) {
      throw OllamaApiException(message: 'Failed to list models: $e');
    }
  }
}

class OllamaResponseChunk {
  final String response;
  final bool done;
  final List<String>? suggestions;
  final Map<String, dynamic>? metrics;

  OllamaResponseChunk({
    required this.response,
    required this.done,
    this.suggestions,
    this.metrics,
  });

  factory OllamaResponseChunk.fromJson(Map<String, dynamic> json) {
    return OllamaResponseChunk(
      response: json['response'],
      done: json['done'] ?? false,
      suggestions: (json['suggestions'] as List?)?.cast<String>(),
      metrics: json['metrics'],
    );
  }
}

class OllamaModel {
  final String name;
  final String model;
  final String modifiedAt;
  final int size;
  final bool supportsSuggestions;
  final List<String>? examplePrompts;

  OllamaModel({
    required this.name,
    required this.model,
    required this.modifiedAt,
    required this.size,
    this.supportsSuggestions = false,
    this.examplePrompts,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'],
      model: json['model'],
      modifiedAt: json['modified_at'],
      size: json['size'],
      supportsSuggestions: json['supports_suggestions'] ?? false,
      examplePrompts: (json['example_prompts'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'model': model,
    'modified_at': modifiedAt,
    'size': size,
    if (supportsSuggestions) 'supports_suggestions': true,
    if (examplePrompts != null) 'example_prompts': examplePrompts,
  };
}

class OllamaApiException implements Exception {
  final int? statusCode;
  final String message;

  OllamaApiException({this.statusCode, required this.message});

  @override
  String toString() =>
      'OllamaApiException: $message'
      '${statusCode != null ? ' (status $statusCode)' : ''}';
}

class OllamaResponse {
  final String response;
  final OllamaModel model;
  final Map<String, dynamic> metrics;
  final DateTime createdAt;
  final List<String>? suggestions;

  OllamaResponse({
    required this.response,
    required this.model,
    required this.metrics,
    required this.createdAt,
    this.suggestions,
  });

  factory OllamaResponse.fromJson(Map<String, dynamic> json) {
    return OllamaResponse(
      response: json['response'],
      model: OllamaModel.fromJson(json['model']),
      metrics: json['metrics'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class ResponseData {
  final String response;
  final List<String> suggestions;

  ResponseData({required this.response, required this.suggestions});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      response: json['response'] as String,
      suggestions: List<String>.from(json['suggestions'] as List<dynamic>),
    );
  }
}

class Part {
  final String text;

  Part({required this.text});

  Map<String, dynamic> toJson() => {'text': text};
}

class Message {
  final String role;
  final List<Part> parts;

  Message({required this.role, required this.parts});

  Map<String, dynamic> toJson() => {
    'role': role,
    'parts': parts.map((part) => part.toJson()).toList(),
  };
}

class PromptData {
  String persona = "";
  String preContext = "";
  List<Part> tasks = [];
  List<String> examples = [];
  List<Message> chatChathistory = [];
  String question = "";
}

class PromptBuilder {
  final List<Message> messages = [];

  void addMessage(String role, String text) {
    messages.add(
      Message(
        role: role,
        parts: [Part(text: text)],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'messages': messages.map((msg) => msg.toJson()).toList(),
  };
}
