import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/coachBot/coachBot_history_controller.dart';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';

class CoachBotHistoryScreen extends StatelessWidget {
  CoachBotHistoryScreen({super.key});
  final controller = Get.put(CoachBotHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // History List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.conversations.isEmpty) {
                  return _buildLoadingState();
                }

                if (controller.conversations.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildHistoryList();
              }),
            ),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'history_screen_title'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Obx(
                  () => Text(
                    'history_screen_subtitle_conversations'.tr(
                      namedArgs: {
                        'count': controller.conversations.length.toString(),
                      },
                    ),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter/Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: const Color(0xFF252836),
            onSelected: (value) {
              controller.sortBy(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Text(
                  'history_filter_recent'.tr(),
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: Text(
                  'history_filter_oldest'.tr(),
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              ),
            ],
          ),
          // Delete all button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: controller.clearAllHistory,
          ),
        ],
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF09FACA)),
          ),
          const SizedBox(height: 16),
          Text(
            'history_state_loading'.tr(),
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
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
              Icons.history,
              size: 64,
              color: Color(0xFF09FACA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'history_state_empty_title'.tr(),
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
              'history_state_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => CoachBotChatScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF09FACA),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'history_btn_start_new'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY LIST ====================
  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: controller.loadHistory,
      color: const Color(0xFF09FACA),
      backgroundColor: const Color(0xFF252836),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.conversations.length,
        itemBuilder: (context, index) {
          final conversation = controller.conversations[index];
          return _buildConversationCard(conversation);
        },
      ),
    );
  }

  // ==================== CONVERSATION CARD ====================
  Widget _buildConversationCard(ConversationHistory conversation) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        controller.deleteConversation(conversation.id);
      },
      child: InkWell(
        onTap: () => controller.openConversation(conversation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF09FACA).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User message (preview)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09FACA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Color(0xFF09FACA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.userMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          conversation.botResponse,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Metadata
              Row(
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    _formatDate(conversation.timestamp),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  if (conversation.tokens > 0)
                    _buildInfoChip(
                      Icons.analytics,
                      'coachbot_badge_tokens'.tr(
                        namedArgs: {'tokens': conversation.tokens.toString()},
                      ),
                      Colors.orange,
                    ),
                  const SizedBox(width: 8),
                  if (conversation.model != null)
                    _buildInfoChip(
                      Icons.memory,
                      conversation.model!.contains('8b')
                          ? 'coachbot_badge_fast'.tr()
                          : 'coachbot_badge_smart'.tr(),
                      Colors.purple,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return 'history_time_minutes_ago'.tr(
        namedArgs: {'minutes': difference.inMinutes.toString()},
      );
    } else if (difference.inHours < 24) {
      return 'history_time_hours_ago'.tr(
        namedArgs: {'hours': difference.inHours.toString()},
      );
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'history_time_days_ago'.tr(
        namedArgs: {'days': difference.inDays.toString()},
      );
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
