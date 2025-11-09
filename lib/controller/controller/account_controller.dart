import 'package:get/get.dart';
import 'package:mapped_frontend/screens/profile_editor_screen.dart';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'notification_controller.dart';

class AccountController extends GetxController {
  var notificationsEnabled = true.obs;
  var securityMethod = 'Fingerprint'.obs;

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
    
    // Navigate to notification screen
    Get.to(() => NotificationScreen());
  }
  
  void editProfile() {
    // Navigate to edit profile page
    Get.to(() => ProfileEditorScreen());
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