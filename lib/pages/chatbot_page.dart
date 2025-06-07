import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Model untuk sebuah pesan dalam chat
class ChatMessage {
  final String text;
  final bool isFromUser;

  ChatMessage({required this.text, required this.isFromUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Assalamualaikum! Saya KyaiQ, asisten AI Anda untuk bertanya seputar agama. Silakan bertanya.',
      isFromUser: false,
    ),
  ];
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      debugPrint("API Key tidak ditemukan. Pastikan file .env sudah benar.");
    }

    _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey!);

    _chat = _model.startChat(
      history: [
        Content.text(
          'Mulai sekarang, kamu adalah "KyaiQ", seorang asisten AI yang menjawab semua pertanyaan seputar agama (Islam, Kristen, Katolik, Hindu, Buddha, Konghucu, dll). Jika pengguna bertanya di luar topik agama, arahkan kembali ke topik seputar agama dengan baik.tetapi jika user tetep ngeyel keluar dari topik agama, gunakan sarkas dan satire',
        ),
      ],
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _isLoading) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isFromUser: true));
      _isLoading = true;
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      final botMessage = response.text;

      if (botMessage == null || botMessage.isEmpty) {
        throw Exception('Menerima respon kosong dari API.');
      }

      setState(() {
        _messages.add(ChatMessage(text: botMessage, isFromUser: false));
      });
    } catch (e) {
      debugPrint("Error saat mengirim pesan: $e");
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Maaf, terjadi sedikit kendala. Bisa diulangi pertanyaannya?",
            isFromUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan skema warna agar mudah diubah
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'KyaiQ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          _buildChatInput(primaryColor: primaryColor),
        ],
      ),
    );
  }

  // Menggunakan BubbleSpecialThree dari package chat_bubbles
  Widget _buildMessageBubble(
    ChatMessage message, {
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    final bool isUser = message.isFromUser;
    return BubbleSpecialThree(
      text: message.text,
      color: isUser ? primaryColor : secondaryColor,
      tail: true,
      isSender: isUser,
      textStyle: TextStyle(
        color:
            isUser
                ? Colors.white
                : Theme.of(context).colorScheme.onSecondaryContainer,
        fontSize: 16,
      ),
    );
  }

  Widget _buildChatInput({required Color primaryColor}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Kirim pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              child: IconButton.filled(
                icon: const Icon(Icons.send_rounded),
                onPressed: _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
