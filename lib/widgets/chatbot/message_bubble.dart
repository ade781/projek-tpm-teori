import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/pages/chatbot_page.dart'; // Ganti dengan lokasi ChatMessage Anda

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isFromUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Widget untuk teks, bisa berupa teks statis atau animasi
    Widget textWidget;

    // Tentukan warna bubble berdasarkan pengirim dan tema
    final bubbleColor =
        isUser
            ? (isDarkMode ? Colors.teal.shade700 : Colors.teal.shade600)
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);

    // Tentukan warna teks berdasarkan pengirim dan tema
    final textColor =
        isUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black87);

    if (isUser) {
      // Pesan dari pengguna ditampilkan secara langsung
      textWidget = Text(
        message.text,
        style: TextStyle(color: textColor, fontSize: 16),
      );
    } else {
      textWidget = AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            message.text,
            textStyle: TextStyle(color: textColor, fontSize: 16),
            speed: const Duration(milliseconds: 12),
          ),
        ],
        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),

        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: bubbleColor,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft:
                isUser ? const Radius.circular(20.0) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(20.0),
          ),
        ),
        // 'child' di sini bisa menerima widget apa pun, sehingga AnimatedTextKit berfungsi.
        child: textWidget,
      ),
    );
  }
}
