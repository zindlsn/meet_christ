import 'package:flutter/material.dart';
import 'package:meet_christ/services/kath_ai_service.dart';
import 'package:meet_christ/services/ollama_service.dart';

class KIChatPage extends StatefulWidget {
  final String chatName;

  const KIChatPage({super.key, required this.chatName});

  @override
  State<KIChatPage> createState() => _KIChatPageState();
}

class _KIChatPageState extends State<KIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        message: 'You started a chat with ${widget.chatName}',
        isMe: false,
        isSystem: true,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(message: message, isMe: true));
      _isLoading = true;
      _suggestions = [];
    });

    try {
      final response = await KathAIService.sendRequest(message);

      setState(() {
        _messages.add(
          ChatMessage(
            message: response.response,
            isMe: false,
            ollamaResponse: response,
          ),
        );
        _suggestions = response.suggestions ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: 'Error: ${e.toString()}',
            isMe: false,
            isError: true,
          ),
        );
        _isLoading = false;
      });
    }
  }

  void _useSuggestion(String suggestion) {
    _messageController.text = suggestion;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                ),
              ),
              // Suggestions chips
              if (_suggestions.isNotEmpty)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _suggestions
                        .map(
                          (suggestion) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ActionChip(
                              label: Text(suggestion),
                              onPressed: () => _useSuggestion(suggestion),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Input area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (_isLoading) const LinearProgressIndicator(minHeight: 2),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isSystem;
  final bool isError;
  final OllamaResponse? ollamaResponse;

  const ChatMessage({
    super.key,
    required this.message,
    this.isMe = false,
    this.isSystem = false,
    this.isError = false,
    this.ollamaResponse,
  });

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.blue[100]
                  : isError
                  ? Colors.red[100]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(message),
          ),
        ],
      ),
    );
  }
}
