import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/screens/profile_editor_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/controller/controller/notification_controller.dart';

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

  @override
  void onInit() {
    super.onInit();
    //Load user data when controller initializes
    fetchUserProfile();
    // Listen to changes from NotificationController if it exists
    ever(notificationsEnabled, (_) => _syncNotificationState());
  }

  // Fetch user profile from backend
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/api/profile/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update reactive variables
        displayName.value = data['name'] ?? 'User';
        displayEmail.value = data['email'] ?? 'email@domain.com';
        displayPhone.value = data['phone'] ?? '000-000-0000';
        
        // Update Profile Image URL
        if (data['avatar'] != null && data['avatar'] != "") {
          profileImageUrl.value = "$baseUrl/${data['avatar']}";
        }

        debugPrint("✅ Profile loaded: ${data['name']}");
      } else {
        debugPrint("❌ Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("💥 Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refresh profile after editing
  Future<void> refreshProfile() async {
    await fetchUserProfile();
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
  
  void editProfile() async {
    final result = await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(),
      ),
    );
    
    // Refresh profile data when returning from editor
    // You can pass a result to indicate if profile was updated
    if (result == true || result == null) {
      await refreshProfile();
    }
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