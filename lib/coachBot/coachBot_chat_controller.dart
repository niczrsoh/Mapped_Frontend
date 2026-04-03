import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';

class CoachBotChatController extends GetxController {
  // Dependencies
  UserController get userController => Get.find<UserController>();

  // Controllers
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // State
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var suggestions = <String>[].obs;
  var insights = Rx<CoachInsights?>(null);

  // Track if we are viewing a specific historical conversation
  bool isHistoryView = false;

  // API Configuration
  final ApiService _apiService = ApiService();
  static const String apiPath = '/api/coachbot';

  @override
  void onInit() {
    super.onInit();

    // Check arguments BEFORE loading welcome message
    if (Get.arguments != null) {
      _handleArguments();
    }

    // Only load welcome message if we aren't viewing history and list is empty
    if (!isHistoryView && messages.isEmpty) {
      _loadWelcomeMessage();
    }

    _loadSuggestions();
    _loadInsights();
  }

  /// Handle arguments passed from other screens (e.g. History Screen)
  void _handleArguments() {
    final args = Get.arguments;

    // Case 1: Viewing History (Map passed from HistoryController)
    if (args is Map<String, dynamic> && args['resumeConversation'] == true) {
      isHistoryView = true;

      final String userMsg = args['userMessage'] ?? '';
      final String botResp = args['botResponse'] ?? '';
      final DateTime timestamp = args['timestamp'] ?? DateTime.now();
      final String? model = args['model'];
      final int tokens = args['tokens'] ?? 0;

      // Add the historical interaction
      if (userMsg.isNotEmpty) {
        messages.add(
          ChatMessage(text: userMsg, isUser: true, timestamp: timestamp),
        );
      }

      if (botResp.isNotEmpty) {
        messages.add(
          ChatMessage(
            text: botResp,
            isUser: false,
            timestamp: timestamp, // or timestamp.add(Duration(seconds: 1))
            model: model,
            tokens: tokens,
            cached: args['cached'] ?? false,
            preset: args['preset'] ?? false,
          ),
        );
      }

      // Scroll to bottom after a slight delay to ensure UI builds
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    }
    // Case 2: Draft Message (String passed as a shortcut)
    else if (args is String) {
      messageController.text = args;
      // We don't send immediately here, let the user press send
    }
  }

  // ==================== API CALLS ====================

  /// Send message to CoachBot API
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    // Add user message to UI
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);
    messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Set loading state
    isLoading.value = true;

    try {
      // Prepare conversation history (last 10 messages)
      final history = _prepareHistory();

      // Prepare user context
      final userContext = {
        'beltLevel': userController.userData['beltLevel'] ?? null,
        'role': userController.userData['role'] ?? 'coach',
        'sessionCount': userController.userData['sessions']?.length ?? 0,
      };

      // Make API request
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}$apiPath/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userController.userData['_id'],
          'message': text,
          'history': history,
          'userContext': userContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Add bot response to UI
        final botMessage = ChatMessage(
          text: data['response'],
          isUser: false,
          timestamp: DateTime.now(),
          cached: data['cached'] ?? false,
          preset: data['preset'] ?? false,
          model: data['model'],
          tokens: data['usage']?['total_tokens'] ?? 0,
        );
        messages.add(botMessage);

        // Show badge if response was instant
        if (data['cached'] == true || data['preset'] == true) {
          _showSuccessSnackbar('coachbot_snackbar_instant_response'.tr());
        }

        // Refresh insights periodically
        if (messages.length % 5 == 0) {
          _loadInsights();
        }
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showErrorMessage(
          error['error'] ?? 'coachbot_error_invalid_request'.tr(),
        );
      } else if (response.statusCode == 429) {
        _showErrorMessage('coachbot_error_too_many_requests'.tr());
      } else {
        _showErrorMessage('coachbot_error_failed_response'.tr());
      }
    } catch (e) {
      print('CoachBot Error: $e');
      _showErrorMessage('error_network'.tr());
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  /// Load quick suggestions from API
  Future<void> _loadSuggestions() async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}$apiPath/suggestions?context=general'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        suggestions.value = data.cast<String>();
      }
    } catch (e) {
      suggestions.value = [
        "coachbot_suggestion_plan_session".tr(),
        "coachbot_suggestion_belt_reqs".tr(),
        "coachbot_suggestion_warmup".tr(),
        "coachbot_suggestion_roundhouse".tr(),
      ];
    }
  }

  /// Load coaching insights/analytics
  Future<void> _loadInsights() async {
    try {
      final userId = userController.userData['_id'];
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}$apiPath/insights/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        insights.value = CoachInsights.fromJson(data);
      }
    } catch (e) {
      debugPrint('Failed to load insights: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  List<Map<String, String>> _prepareHistory() {
    final historyLimit = 10;
    final recentMessages = messages.length > historyLimit
        ? messages.sublist(messages.length - historyLimit)
        : messages;

    return recentMessages.map((msg) {
      return {'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text};
    }).toList();
  }

  void _loadWelcomeMessage() {
    final userName =
        userController.userData['name'] ?? 'coachbot_ctrl_fallback_name'.tr();
    messages.add(
      ChatMessage(
        text: "coachbot_msg_welcome".tr(namedArgs: {'userName': userName}),
        isUser: false,
        timestamp: DateTime.now(),
        preset: true,
      ),
    );
  }

  void _showErrorMessage(String error) {
    messages.add(
      ChatMessage(
        text: "coachbot_msg_error_response".tr(namedArgs: {'error': error}),
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'success'.tr(),
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // ==================== UI ACTIONS ====================

  void onSuggestionTapped(String suggestion) {
    messageController.text = suggestion;
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: messageController.text.length),
    );
  }

  void startVoiceInput() {
    Get.snackbar(
      'coachbot_snackbar_voice_title'.tr(),
      'coachbot_snackbar_voice_msg'.tr(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void clearConversation() {
    Get.defaultDialog(
      title: 'coachbot_dialog_clear_title'.tr(),
      middleText: 'coachbot_dialog_clear_msg'.tr(),
      textConfirm: 'coachbot_btn_clear'.tr(),
      textCancel: 'cancel'.tr(),
      confirmTextColor: Colors.white,
      onConfirm: () {
        messages.clear();
        isHistoryView =
            false; // Reset history mode so welcome message comes back
        _loadWelcomeMessage();
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// ==================== DATA MODELS ====================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool cached;
  final bool preset;
  final String? model;
  final int tokens;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.cached = false,
    this.preset = false,
    this.model,
    this.tokens = 0,
    this.isError = false,
  });
}

class CoachInsights {
  final int totalQueries;
  final List<TopicCount> topTopics;
  final double avgTokensPerQuery;

  CoachInsights({
    required this.totalQueries,
    required this.topTopics,
    required this.avgTokensPerQuery,
  });

  factory CoachInsights.fromJson(Map<String, dynamic> json) {
    return CoachInsights(
      totalQueries: json['totalQueries'] ?? 0,
      topTopics:
          (json['topTopics'] as List?)
              ?.map((t) => TopicCount.fromJson(t))
              .toList() ??
          [],
      avgTokensPerQuery: (json['avgTokensPerQuery'] ?? 0).toDouble(),
    );
  }
}

class TopicCount {
  final String topic;
  final int count;

  TopicCount({required this.topic, required this.count});

  factory TopicCount.fromJson(Map<String, dynamic> json) {
    return TopicCount(topic: json['topic'] ?? '', count: json['count'] ?? 0);
  }
}
