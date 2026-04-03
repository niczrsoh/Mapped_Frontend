import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';
import 'package:mapped_frontend/services/api_service.dart';

class CoachBotHistoryController extends GetxController {
  // Dependencies
  UserController get userController => Get.find<UserController>();

  // State
  var conversations = <ConversationHistory>[].obs;
  var isLoading = false.obs;

  // API Configuration
  final ApiService _apiService = ApiService();
  static const String apiPath = '/api/coachbot';

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// Load chat history from API
  Future<void> loadHistory() async {
    isLoading.value = true;

    try {
      final userId = userController.userData['_id'];
      if (userId == null) {
        _showError('error_not_logged_in'.tr());
        return;
      }

      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}$apiPath/history/$userId?limit=50'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> historyList = data['history'] ?? [];

        conversations.value = historyList.map((item) {
          return ConversationHistory.fromJson(item);
        }).toList();

        debugPrint('✅ Loaded ${conversations.length} conversations');
      } else {
        _showError('history_error_load_failed'.tr());
      }
    } catch (e) {
      debugPrint('History Error: $e');
      _showError('error_network'.tr());
    } finally {
      isLoading.value = false;
    }
  }

  /// Sort conversations
  void sortBy(String sortType) {
    if (sortType == 'recent') {
      conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (sortType == 'oldest') {
      conversations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  /// Delete a single conversation
  void deleteConversation(String conversationId) {
    conversations.removeWhere((conv) => conv.id == conversationId);

    Get.snackbar(
      'deleted'.tr(),
      'history_snackbar_deleted_msg'.tr(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Clear all history
  void clearAllHistory() {
    Get.defaultDialog(
      title: 'history_dialog_clear_all_title'.tr(),
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF252836),
      middleText: 'history_dialog_clear_all_msg'.tr(),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'history_btn_clear_all'.tr(),
      textCancel: 'cancel'.tr(),
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        conversations.clear();
        Get.back();
        Get.snackbar(
          'history_snackbar_cleared_title'.tr(),
          'history_snackbar_cleared_msg'.tr(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF09FACA),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  /// Open a conversation (navigate to chat with context)
  void openConversation(ConversationHistory conversation) {
    // Navigate to chat screen and pass the conversation details
    Get.to(
      () => CoachBotChatScreen(),
      arguments: {
        'resumeConversation': true,
        'userMessage': conversation.userMessage,
        'botResponse': conversation.botResponse,
        'timestamp': conversation.timestamp,
        'model': conversation.model,
        'tokens': conversation.tokens,
        'cached': conversation.cached,
        'preset': conversation.preset,
      },
      preventDuplicates: false,
    );
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'error'.tr(),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }
}

// ==================== DATA MODEL ====================

class ConversationHistory {
  final String id;
  final String userMessage;
  final String botResponse;
  final DateTime timestamp;
  final int tokens;
  final String? model;

  // These fields caused the error. We keep them non-nullable (bool)
  // but ensure we provide default values in the constructor and fromJson.
  final bool? cached;
  final bool? preset;

  ConversationHistory({
    required this.id,
    required this.userMessage,
    required this.botResponse,
    required this.timestamp,
    this.tokens = 0,
    this.model,
    this.cached = false,
    this.preset = false,
  });

  factory ConversationHistory.fromJson(Map<String, dynamic> json) {
    return ConversationHistory(
      id: json['_id'] ?? '',
      userMessage: json['userMessage'] ?? '',
      botResponse: json['botResponse'] ?? '',
      timestamp: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      tokens: json['tokensUsed']?['total_tokens'] ?? 0,
      model: json['model'],
      // FIX: Use '?? false' to handle nulls from API safely
      cached: json['cached'] ?? false,
      preset: json['preset'] ?? false,
    );
  }
}
