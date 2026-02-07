import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/coachBot/coachBot_chat_controller.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

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
            _buildHeader(),

            // Chat Messages
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMessageList();
              }),
            ),

            // Suggestions (shown when no messages or after welcome)
            Obx(() {
              if (controller.messages.length <= 1 &&
                  controller.suggestions.isNotEmpty) {
                return _buildSuggestions();
              }
              return const SizedBox.shrink();
            }),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                Obx(() => Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.isLoading.value
                                ? Colors.orange
                                : const Color(0xFF09FACA),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.isLoading.value
                              ? 'Thinking...'
                              : 'Ready to help',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          // Insights badge
          Obx(() {
            final insights = controller.insights.value;
            if (insights != null && insights.totalQueries > 0) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF09FACA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics,
                        color: Color(0xFF09FACA), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${insights.totalQueries}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF09FACA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: controller.clearConversation,
          ),
        ],
      ),
    );
  }

  // ==================== MESSAGE LIST ====================
  Widget _buildMessageList() {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];

        // Show timestamp for first message or if 5+ minutes gap
        bool showTimestamp = index == 0;
        if (index > 0) {
          final prevMessage = controller.messages[index - 1];
          final timeDiff =
              message.timestamp.difference(prevMessage.timestamp).inMinutes;
          showTimestamp = timeDiff >= 5;
        }

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.timestamp),
            message.isUser
                ? _buildUserMessage(message)
                : _buildBotMessage(message),
          ],
        );
      },
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF09FACA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_martial_arts,
              size: 64,
              color: Color(0xFF09FACA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to CoachBot!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your AI-powered Taekwondo coaching assistant',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUGGESTIONS ====================
  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try asking:',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.suggestions
                .map((suggestion) => _buildSuggestionChip(suggestion))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return InkWell(
      onTap: () => controller.onSuggestionTapped(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF09FACA).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF09FACA).withOpacity(0.3),
          ),
        ),
        child: Text(
          suggestion,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: const Color(0xFF09FACA),
          ),
        ),
      ),
    );
  }

  // ==================== TIMESTAMP ====================
  Widget _buildTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    String displayText;
    if (difference.inDays == 0) {
      // Today - show time
      displayText =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      displayText = 'Yesterday';
    } else if (difference.inDays < 7) {
      displayText = '${difference.inDays} days ago';
    } else {
      displayText =
          "${time.day}/${time.month}/${time.year}";
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF252836).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayText,
          style: GoogleFonts.roboto(fontSize: 11, color: Colors.white54),
        ),
      ),
    );
  }

  // ==================== BOT MESSAGE ====================
  Widget _buildBotMessage(ChatMessage message) {
    final textColor = message.isError
        ? Colors.red[300]
        : const Color(0xFF1A1D29);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: message.isError
                ? Colors.red.withOpacity(0.3)
                : const Color(0xFF09FACA),
            child: Icon(
              message.isError ? Icons.error_outline : Icons.sports_martial_arts,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isError
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: MarkdownBody(
                    data: message.text,
                    selectable: true, // Allows users to copy text
                    styleSheet: MarkdownStyleSheet(
                      // Normal text style
                      p: GoogleFonts.roboto(
                        fontSize: 14,
                        color: textColor,
                        height: 1.5,
                      ),
                      // Bold text style (**text**)
                      strong: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w700, // Bold weight
                        color: textColor,
                      ),
                      // List bullet style
                      listBullet: GoogleFonts.roboto(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Message metadata (badges)
                Wrap(
                  spacing: 6,
                  children: [
                    if (message.preset)
                      _buildBadge('📚 Quick Answer', Colors.blue),
                    if (message.cached)
                      _buildBadge('⚡ Instant', Colors.green),
                    if (message.tokens > 0)
                      _buildBadge(
                          '${message.tokens} tokens', Colors.orange),
                    if (message.model != null)
                      _buildBadge(
                        message.model!.contains('8b') ? 'Fast' : 'Smart',
                        Colors.purple,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==================== USER MESSAGE ====================
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF09FACA), Color(0xFF0A8FD9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF09FACA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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

  // ==================== INPUT BAR ====================
  Widget _buildInputBar() {
    return Container(
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
                maxLength: 500,
                buildCounter: (context,
                    {required currentLength,
                    required isFocused,
                    maxLength}) {
                  // Show character count when > 400 chars
                  if (currentLength > 400) {
                    return Text(
                      '$currentLength/$maxLength',
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: currentLength >= 500
                            ? Colors.red
                            : Colors.white38,
                      ),
                    );
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ask me anything about Taekwondo coaching...',
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
          Obx(() => Container(
                decoration: BoxDecoration(
                  gradient: controller.isLoading.value
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF09FACA), Color(0xFF0A8FD9)],
                        ),
                  color: controller.isLoading.value
                      ? Colors.grey
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.sendMessage,
                ),
              )),
        ],
      ),
    );
  }
}