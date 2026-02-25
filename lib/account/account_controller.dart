// controllers/account_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/profile_editor/profile_editor_screen.dart';
import 'package:mapped_frontend/help_support/help_support_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/controller/controller/notification_controller.dart';
import 'package:mapped_frontend/account/account_model.dart';
import 'package:mapped_frontend/language/language_screen.dart';
import 'package:mapped_frontend/language/language_controller.dart';
import 'package:mapped_frontend/text_size/text_size_controller.dart';
import 'package:mapped_frontend/account/account_screen.dart';
import 'package:mapped_frontend/screens/about_us_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountController extends GetxController {
  var notificationsEnabled = true.obs;
  var securityMethod = 'security_ctrl_method_fingerprint'.tr().obs;
  var isLoading = false.obs;

  UserController get userController => Get.find<UserController>();
  final languageController = Get.put(LanguageController());
  final textSizeController = Get.put(TextSizeController());

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    ever(notificationsEnabled, (_) => _syncNotificationState());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.userData.isEmpty) {
        fetchUserData();
      }
    });

    _syncNotificationState();
  }

  void _syncNotificationState() {
    if (Get.isRegistered<NotificationController>()) {
      final notifController = Get.find<NotificationController>();
      notificationsEnabled.value = notifController.generalNotification.value;
    }
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      await userController.fetchUserProfile();
    } catch (e) {
      _showErrorDialog('account_error_load_profile'.tr());
    } finally {
      isLoading.value = false;
    }
  }

  AccountHeaderData get headerData {
    final user = userController.userData;
    final avatarValue = user['avatar']?.toString() ?? '';
    print('🖼️ AccountController headerData - avatar value: "$avatarValue"');
    print('🖼️ Full user data: $user');
    return AccountHeaderData(
      name: userController.userName,
      email: user['email']?.toString() ?? 'account_lbl_no_email'.tr(),
      avatar: avatarValue,
      createdAt: user['createdAt']?.toString(),
    );
  }

  List<AccountSection> getAccountSections(BuildContext context) {
    return [
      // First Section - Dark (Profile & Notifications)
      AccountSection(
        isDark: true,
        items: [
          AccountMenuItem(
            iconPath: 'assets/images/profile.png',
            text: 'account_menu_edit_profile'.tr(),
            onTap: () => navigateToProfileEditor(context),
          ),
          AccountMenuItem(
            iconPath: 'assets/images/notification.png',
            text: 'account_menu_notifications'.tr(),
            badge: notificationsEnabled.value ? 'account_menu_on'.tr() : 'account_menu_off'.tr(),
            badgeColor: Color(0xFF09FACA),
            onTap: () => navigateToNotifications(context),
          ),
          AccountMenuItem(
            iconPath: 'assets/images/logout.png',
            text: 'account_menu_logout'.tr(),
            onTap: logout,
          ),
        ],
      ),

      // Second Section - Light (Security & Language)
      AccountSection(
        isDark: false,
        items: [
          AccountMenuItem(
            iconPath: 'assets/images/security.png',
            text: 'account_menu_security'.tr(),
            badge: securityMethod.value,
            badgeColor: Color(0xFF09FACA),
            onTap: navigateToSecurity,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/language.png',
            text: 'account_menu_language'.tr(),
            badge: languageController.languages.firstWhere(
              (l) => l['code'] == languageController.currentLanguage.value,
            )['name'],
            badgeColor: Color(0xFF09FACA),
            onTap: navigateToLanguage,
          ),
        ],
      ),

      // Third Section - Dark (Help & Info)
      AccountSection(
        isDark: true,
        items: [
          AccountMenuItem(
            iconPath: 'assets/images/help.png',
            text: 'account_menu_help_support'.tr(),
            onTap: navigateToHelp,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/privacy.png',
            text: 'account_menu_privacy_policy'.tr(),
            onTap: navigateToPrivacy,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/about.png',
            text: 'account_menu_about_us'.tr(),
            onTap: navigateToAbout,
          ),
        ],
      ),

      AccountSection(
        isDark: true,
        items: [
          AccountMenuItem(
            iconPath: 'assets/images/text_size.png', // Ensure this asset exists
            text: 'account_menu_text_size'.tr(),
            subtitle: 'account_menu_text_size_subtitle'.tr(),
            onTap: () => _handleTextSizeAdjustment(),
          ),
        ],
      ),
    ];
  }

  // Navigation Methods
  Future<void> navigateToProfileEditor(BuildContext context) async {
    // Navigate and wait for result
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProfileEditorScreen(userData: userController.userData),
      ),
    );

    await fetchUserData();
  }

  void navigateToNotifications(BuildContext context) {
    final notifController = Get.put(NotificationController());

    notificationsEnabled.value = notifController.generalNotification.value;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => NotificationScreen()));
  }

  void navigateToSecurity() {
    Get.toNamed('/security');
  }

  void navigateToLanguage() {
    Get.to(() => LanguageScreen());
  }

  void navigateToHelp() {
    Get.to(() => HelpSupportScreen());
  }

  void navigateToPrivacy() {
    Get.toNamed('/privacy-policy');
  }

  void navigateToAbout() {
    Get.to(() => const AboutUsScreen());
  }

  // Logout Method
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'logout'.tr(),
      middleText: 'account_dialog_logout_msg'.tr(),
      textConfirm: 'account_dialog_btn_yes'.tr(),
      textCancel: 'account_dialog_btn_no'.tr(),
      confirmTextColor: Colors.white,
      cancelTextColor: Color(0xFF09FACA),
      buttonColor: Color(0xFF09FACA),
      onConfirm: () async {
        try {
          await _performLogout();
          Get.back();
          Get.offAllNamed('/login');
        } catch (e) {
          Get.back();
          _showErrorDialog('account_error_logout_failed'.tr());
        }
      },
    );
  }

  /// Perform logout operations
  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar');
    await prefs.remove('user_role');

    // Clear user controller data
    userController.userData.value = {};
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'error'.tr(),
      middleText: message,
      textConfirm: 'ok'.tr(),
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }

  void _handleTextSizeAdjustment() async {
    Get.offAllNamed('/home');

    await Future.delayed(const Duration(milliseconds: 300));

    Get.bottomSheet(
      TextSizeBottomSheet(),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}
