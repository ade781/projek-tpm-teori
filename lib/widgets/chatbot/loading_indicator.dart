import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChatLoadingIndicator extends StatelessWidget {
  const ChatLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Lottie.asset(
          'assets/chat_loading.json',
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}