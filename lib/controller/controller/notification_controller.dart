import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationController extends GetxController {
  // Common
  var generalNotification = true.obs;
  var sound = false.obs;
  var vibrate = true.obs;
  
  // System & services update
  var appUpdates = false.obs;
  var billReminder = true.obs;
  var promotion = true.obs;
  var discountAvailable = false.obs;
  var paymentRequest = false.obs;
  
  // Others
  var newServiceAvailable = false.obs;
  var newTipsAvailable = true.obs;
  
  void saveSettings() {
    // Save notification settings to backend/storage
    Get.snackbar(
      'Success',
      'Notification settings saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF09FACA),
      colorText: Color(0xFF1A1D29),
      duration: Duration(seconds: 2),
    );
  }
}