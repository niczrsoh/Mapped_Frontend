import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/account/account_controller.dart';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';
import 'package:mapped_frontend/controller/user_controller';

class CoachBotController extends GetxController {
  UserController get userController => Get.find<UserController>();
  late RxString userName;

  @override
  void onInit() {
    userName =
        userController.userData['name']?.toString().obs ??
        'coachbot_ctrl_fallback_name'.tr().obs;
    super.onInit();
  }

  final messageController = TextEditingController();

  // Navigate to chat with optional draft message
  void _navigateToChatWithDraft(String? draftText) {
    Get.to(() => CoachBotChatScreen(), arguments: draftText);
  }

  // ==================== METHODS CALLED BY CoachBotScreen ====================

  // Quick action buttons matching your screen
  void explainHistory() {
    _navigateToChatWithDraft('coachbot_draft_history'.tr());
  }

  void showTechniques() {
    _navigateToChatWithDraft('coachbot_draft_techniques'.tr());
  }

  void findDojang() {
    _navigateToChatWithDraft('coachbot_draft_find_dojang'.tr());
  }

  void showOtherOptions() {
    _navigateToChatWithDraft('coachbot_draft_other_options'.tr());
  }

  // ==================== ADDITIONAL USEFUL METHODS ====================

  void explainBeltRequirements() {
    _navigateToChatWithDraft('coachbot_draft_belt_reqs'.tr());
  }

  void planSession() {
    _navigateToChatWithDraft('coachbot_draft_plan_session'.tr());
  }

  void showWarmUp() {
    _navigateToChatWithDraft('coachbot_draft_warmup'.tr());
  }

  void teachTechnique() {
    _navigateToChatWithDraft('coachbot_draft_roundhouse'.tr());
  }

  void sparringDrills() {
    _navigateToChatWithDraft('coachbot_draft_sparring'.tr());
  }

  void injuryPrevention() {
    _navigateToChatWithDraft('coachbot_draft_injury'.tr());
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
      'coachbot_snackbar_voice_title'.tr(),
      'coachbot_snackbar_voice_msg'.tr(),
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
    // messageController.dispose();
    super.onClose();
  }
}
