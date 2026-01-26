import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/screens/profile_editor_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/controller/controller/notification_controller.dart';

class AccountController extends GetxController {
  var notificationsEnabled = true.obs;
  var securityMethod = 'Fingerprint'.obs;
  
  // Get the UserController instance
  UserController get userController => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    // Listen to changes from NotificationController if it exists
    ever(notificationsEnabled, (_) => _syncNotificationState());
    
    // Fetch user data on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.userData.isEmpty) {
        userController.fetchUserProfile();
      }
    });
  }
  
  void _syncNotificationState() {
    // Sync with NotificationController when it's registered
    if (Get.isRegistered<NotificationController>()) {
      final notifController = Get.find<NotificationController>();
      notificationsEnabled.value = notifController.generalNotification.value;
    }
  }
  
  void navigateToNotifications() {
    // Get or create the notification controller
    final notifController = Get.put(NotificationController());
    
    // Sync the state before navigating
    notificationsEnabled.value = notifController.generalNotification.value;
    
    Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (context) => NotificationScreen(),
      ),
    );
  }
  
  void editProfile() {
    // Pass user data to profile editor
    Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(
          userData: userController.userData.value,
        ),
      ),
    );
  }
  
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () async {
        // Navigate to login
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }
  
  void navigateToSecurity() {
    Get.toNamed('/security');
  }
  
  void navigateToLanguage() {
    Get.toNamed('/language');
  }
  
  void navigateToHelp() {
    Get.toNamed('/help-support');
  }
  
  void navigateToPrivacy() {
    Get.toNamed('/privacy-policy');
  }
  
  void navigateToAbout() {
    Get.toNamed('/about-us');
  }
}