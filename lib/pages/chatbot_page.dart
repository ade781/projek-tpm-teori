import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


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

    _model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey!);

    _chat = _model.startChat(
      history: [
        Content.text(
          'Mulai sekarang, kamu adalah "KyaiQ", seorang asisten AI yang menjawab semua pertanyaan seputar agama (Islam, Kristen, Katolik, Hindu, Buddha, Konghucu, dll). Jika pengguna bertanya di luar topik agama, arahkan kembali ke topik seputar agama dengan baik. tetapi jika user tetep ngeyel keluar dari topik agama, gunakan sarkas dan satire. kalo ngomong gausah pake * '
          'jika user keluar dari topik agama, arah kan perlahan agar tetap pada topik agama, tetapi jika tetep ngeyel marahin aja dengan sarkas'
          'berikan jawaban jangan terlalu panjang, cukup 1 paragraf aja dan jika perlu 2 boleh'
          'gausah ada kata yang dicetak tebal dengan bintang',
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KyaiQ',
          style: TextStyle(
            fontWeight: FontWeight.w700, 
            fontSize: 25,
            color: const Color.fromARGB(
              255,
              255,
              255,
              255,
            ), // Warna biru-abu gelap yang modern
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                blurRadius: 2.0, 
                color: Colors.black.withOpacity(0.2), 
                offset: Offset(1.0, 1.0), 
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [
                        const Color.fromARGB(255, 199, 110, 94),
                        const Color.fromARGB(255, 216, 97, 136),
                      ]
                      : [
                        const Color.fromARGB(255, 163, 60, 184),
                        const Color.fromARGB(255, 138, 104, 170),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? LinearGradient(
                    colors: [Colors.grey.shade900, Colors.grey.shade800],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                  : LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildMessageBubble(message, isDarkMode: isDarkMode),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.teal.shade300 : Colors.teal,
                    ),
                  ),
                ),
              ),
            _buildChatInput(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, {required bool isDarkMode}) {
    final bool isUser = message.isFromUser;
    return BubbleSpecialThree(
      text: message.text,
      color:
          isUser
              ? isDarkMode
                  ? Colors.teal.shade700
                  : Colors.teal.shade600
              : isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
      tail: true,
      isSender: isUser,
      textStyle: TextStyle(
        color:
            isUser
                ? Colors.white
                : isDarkMode
                ? Colors.white
                : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildChatInput({required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor:
                    isDarkMode ? Colors.teal.shade600 : Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.white,
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
