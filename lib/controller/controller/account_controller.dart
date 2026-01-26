import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/profile_editor_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/controller/controller/notification_controller.dart';
import 'package:mapped_frontend/services/api_service.dart';

class AccountController extends GetxController {
  var notificationsEnabled = true.obs;
  var securityMethod = 'Fingerprint'.obs;

   // User profile observables
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userCountry = ''.obs;
  var userGender = ''.obs;
  var userAddress = ''.obs;
  var userAvatar = ''.obs;
  var userId = ''.obs;
  var isLoading = true.obs;
  
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    // Listen to changes from NotificationController if it exists
    ever(notificationsEnabled, (_) => _syncNotificationState());
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
  
  void editProfile() 
  {
    Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(),
      ),
    );
  }
  
  void logout() {
    // Handle logout logic
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () {
        // Perform logout
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