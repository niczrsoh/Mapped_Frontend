import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/screens/profile_editor_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/controller/controller/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController {
  final String baseUrl = kIsWeb
      ? "http://localhost:5000" // If Chrome: Use localhost
      : "http://10.0.2.2:5000"; // If Android Emulator: Use 10.0.2.2
  // Note: If using a real physical phone, replace 10.0.2.2 with IP address
  final String userId = "692a8a206881c040ebf00943";
  
  // Reactive variables for user data
  var displayName = 'User'.obs;
  var displayEmail = 'email@domain.com'.obs;
  var displayPhone = '000-000-0000'.obs;
  var profileImageUrl = ''.obs;
  var isLoading = false.obs;

  var notificationsEnabled = true.obs;
  var securityMethod = 'Fingerprint'.obs;
  
  // Get the UserController instance
  UserController get userController => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    //Load user data when controller initializes
    fetchUserProfile();
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
    
    // Refresh profile data when returning from editor
    // You can pass a result to indicate if profile was updated
    if (result == true || result == null) {
      await refreshProfile();
    }
  }
  
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () async {
        // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_avatar');
      await prefs.remove('user_role');
          
        // Navigate to login
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }

   // Fetch user profile from API
  Future<void> fetchUserProfile() async {
    if (userName.isEmpty) return;
    
    isLoading.value = true;
    
    final result = await _apiService.getUserProfile(userId.value);
    
    if (result['success'] == true) {
      final userData = result['data'];
      
      // Update observable variables
      userName.value = userData['name'] ?? '';
      userEmail.value = userData['email'] ?? '';
      userPhone.value = userData['phone'] ?? '';
      userCountry.value = userData['country'] ?? '';
      userGender.value = userData['gender'] ?? '';
      userAddress.value = userData['address'] ?? '';
      userAvatar.value = userData['avatar'] ?? '';
      
      print('User profile loaded: ${userData['name']}');
    } else {
      print('Failed to load user profile: ${result['error']}');
      Get.snackbar(
        'Error',
        'Failed to load profile: ${result['error']}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    isLoading.value = false;
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