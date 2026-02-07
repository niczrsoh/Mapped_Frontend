import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';
import 'package:mapped_frontend/controller/user_controller';

class CoachBotController extends GetxController {
  UserController get userController => Get.find<UserController>();
  late RxString userName;

  @override
  void onInit() {
    userName = userController.userData['name']?.toString().obs ?? 'Coach'.obs;
    super.onInit();
  }

  final messageController = TextEditingController();
  
  // Navigate to chat with optional draft message
  void _navigateToChatWithDraft(String? draftText) {
    Get.to(
      () => CoachBotChatScreen(),
      arguments: draftText,
    );
  }

  // ==================== METHODS CALLED BY CoachBotScreen ====================
  
  // Quick action buttons matching your screen
  void explainHistory() {
    _navigateToChatWithDraft('Explain Taekwondo History & Philosophy');
  }

  void showTechniques() {
    _navigateToChatWithDraft('Show me Taekwondo Techniques');
  }

  void findDojang() {
    _navigateToChatWithDraft('Find a Training Hall Nearby');
  }

  void showOtherOptions() {
    _navigateToChatWithDraft('Show me other options');
  }

  // ==================== ADDITIONAL USEFUL METHODS ====================
  
  void explainBeltRequirements() {
    _navigateToChatWithDraft('What are the belt requirements?');
  }

  void planSession() {
    _navigateToChatWithDraft('Help me plan a training session');
  }

  void showWarmUp() {
    _navigateToChatWithDraft('Show me a warm-up routine');
  }

  void teachTechnique() {
    _navigateToChatWithDraft('How do I teach roundhouse kicks?');
  }

  void sparringDrills() {
    _navigateToChatWithDraft('Suggest sparring drills for beginners');
  }

  void injuryPrevention() {
    _navigateToChatWithDraft('What are common injuries and how to prevent them?');
  }

  // ==================== INPUT HANDLING ====================
  
  // Send typed message from main screen
  void sendMessage(String message) {
    final text = message.trim();
    if (text.isEmpty) return;

    messageController.clear();
    _navigateToChatWithDraft(text);
  }

  // Voice input placeholder
  void startVoiceInput() {
    Get.snackbar(
      'Voice Input',
      'Voice input coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Open chat without any preset
  void openChat() {
    _navigateToChatWithDraft(null);
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}