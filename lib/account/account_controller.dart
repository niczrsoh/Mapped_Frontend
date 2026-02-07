// controllers/account_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class AccountController extends GetxController {
  var notificationsEnabled = true.obs;
  var securityMethod = 'Fingerprint'.obs;
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
      _showErrorDialog('Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  AccountHeaderData get headerData {
    final user = userController.userData.value;
    return AccountHeaderData(
      name: userController.userName,
      email: user['email'] ?? 'No email',
      avatar: user['avatar'] ?? '',
      createdAt: user['createdAt'],
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
            text: 'Edit profile information',
            onTap: () => navigateToProfileEditor(context),
          ),
          AccountMenuItem(
            iconPath: 'assets/images/notification.png',
            text: 'Notifications',
            badge: notificationsEnabled.value ? 'ON' : 'OFF',
            badgeColor: Color(0xFF09FACA),
            onTap: () => navigateToNotifications(context),
          ),
          AccountMenuItem(
            iconPath: 'assets/images/logout.png',
            text: 'Log Out',
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
            text: 'Security',
            badge: securityMethod.value,
            badgeColor: Color(0xFF09FACA),
            onTap: navigateToSecurity,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/language.png',
            text: 'Language',
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
            text: 'Help & Support',
            onTap: navigateToHelp,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/privacy.png',
            text: 'Privacy policy',
            onTap: navigateToPrivacy,
          ),
          AccountMenuItem(
            iconPath: 'assets/images/about.png',
            text: 'About Us',
            onTap: navigateToAbout,
          ),
        ],
      ),

      AccountSection(
        isDark: true,
        items: [
          AccountMenuItem(
            iconPath: 'assets/images/text_size.png', // Ensure this asset exists
            text: 'Text Size',
            subtitle: 'Adjust text size in the app',
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
            ProfileEditorScreen(userData: userController.userData.value),
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
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'No',
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
          _showErrorDialog('Failed to logout. Please try again.');
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
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
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
