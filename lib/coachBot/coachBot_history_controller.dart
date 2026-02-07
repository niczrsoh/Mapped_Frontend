import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';
import 'package:mapped_frontend/helper/constants.dart';

class CoachBotHistoryController extends GetxController {
  // Dependencies
  UserController get userController => Get.find<UserController>();

  // State
  var conversations = <ConversationHistory>[].obs;
  var isLoading = false.obs;

  // API Configuration
  static const String baseUrl = apiBaseUrl;
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
        _showError('User not logged in');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl$apiPath/history/$userId?limit=50'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> historyList = data['history'] ?? [];

        conversations.value = historyList.map((item) {
          return ConversationHistory.fromJson(item);
        }).toList();

        debugPrint('✅ Loaded ${conversations.length} conversations');
      } else {
        _showError('Failed to load history');
      }
    } catch (e) {
      debugPrint('History Error: $e');
      _showError('Network error. Please check your connection.');
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
      'Deleted',
      'Conversation removed',
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
      title: 'Clear All History',
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF252836),
      middleText: 'Are you sure you want to delete all conversations? This cannot be undone.',
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        conversations.clear();
        Get.back();
        Get.snackbar(
          'Cleared',
          'All history deleted',
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
      'Error',
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
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      tokens: json['tokensUsed']?['total_tokens'] ?? 0,
      model: json['model'],
      // FIX: Use '?? false' to handle nulls from API safely
      cached: json['cached'] ?? false,
      preset: json['preset'] ?? false,
    );
  }
}