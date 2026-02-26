import 'package:get/get.dart' hide Trans;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
      'success'.tr(),
      'notification_snackbar_success_msg'.tr(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF09FACA),
      colorText: Color(0xFF1A1D29),
      duration: Duration(seconds: 2),
    );
  }
}