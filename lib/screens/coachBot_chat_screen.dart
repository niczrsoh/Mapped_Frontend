import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachBotChatScreen extends StatelessWidget {
  CoachBotChatScreen({super.key});
  final controller = Get.put(CoachBotChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF09FACA),
                    child: const Icon(
                      Icons.sports_martial_arts,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CoachBot',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF09FACA),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Always active',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];

                    if (index == 0) {
                      return Column(
                        children: [
                          _buildTimestamp(message.timestamp),
                          const SizedBox(height: 12),
                          message.isUser
                              ? _buildUserMessage(message)
                              : _buildBotMessage(message),
                        ],
                      );
                    }

                    return message.isUser
                        ? _buildUserMessage(message)
                        : _buildBotMessage(message);
                  },
                ),
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D29),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252836),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        style: GoogleFonts.roboto(color: Colors.white),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Enter a prompt here...',
                          hintStyle: GoogleFonts.roboto(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white54),
                            onPressed: controller.startVoiceInput,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (value) => controller.sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF09FACA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamp(DateTime time) {
    // This will format the time as "HH:MM" (e.g., "14:35")
    final String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF252836).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          formattedTime, // <-- CHANGED
          style: GoogleFonts.roboto(fontSize: 11, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF09FACA),
            child: const Icon(
              Icons.sports_martial_arts,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: const Color(0xFF1A1D29),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF09FACA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class CoachBotChatController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  var messages = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Welcome message
    messages.add(
      ChatMessage(
        text:
            "Hello, I'm CoachBot! 🥋 I'm your personal Taekwondo assistant. How can I help you learn about techniques, history or find a training hall?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    // Check for draft message from arguments
    if (Get.arguments != null && Get.arguments is String) {
      _fillInputBuffer(Get.arguments);
    }
  }

  // This function fills text and moves cursor to end
  void _fillInputBuffer(String text) {
    messageController.text = text;

    // Move cursor to the very end of the text
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: messageController.text.length),
    );
  }

  // Call this when user taps a Chip inside the chat
  void onPromptTapped(String prompt) {
    _fillInputBuffer(prompt);
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Generate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      _generateBotResponse(text);
    });
  }

  void _generateBotResponse(String userMessage) {
    String response;

    final lowerMessage = userMessage.toLowerCase();

    // --- TAEKWONDO LOGIC ---
    if (lowerMessage.contains('history') ||
        lowerMessage.contains('philosophy')) {
      response =
          '''Taekwondo is a Korean martial art that emphasizes high, fast and spinning kicks. 🇰🇷

Its philosophy is built upon five tenets:
• **Courtesy** 
• **Integrity** 
• **Perseverance** 
• **Self-Control** 
• **Indomitable Spirit**''';
    } else if (lowerMessage.contains('techniques') ||
        lowerMessage.contains('kicks') ||
        lowerMessage.contains('poomsae')) {
      response =
          '''Taekwondo is known for its dynamic kicks! Key techniques include:

• **Front Kick**
• **Roundhouse Kick**
• **Side Kick** 
• **Back Kick**

We also practice forms, which are set patterns of defense and attack used to practice techniques.''';
    } else if (lowerMessage.contains('training hall') ||
        lowerMessage.contains('nearby') ||
        lowerMessage.contains('find')) {
      response =
          "To find a training hall near you, I'll need your current location or a city name. Would you like me to search for certified training hall in your area?";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      response =
          "Hello! How can I assist you with Taekwondo today? I can help with history, techniques or finding a school.";
    } else {
      response =
          "I can help you with:\n\n• Taekwondo History & Philosophy\n• Kicks and Forms\n• Finding a local training hall\n\nWhat would you like to know more about?";
    }

    messages.add(
      ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
    );

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void startVoiceInput() {
    Get.snackbar(
      'Voice Input',
      'Listening...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
