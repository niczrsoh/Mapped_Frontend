import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../account/account_controller.dart';

class SecurityController extends GetxController {
  var biometricEnabled = true.obs;
  var twoFactorEnabled = true.obs;
  
  @override
  void onInit() {
    super.onInit();

    // Sync with AccountController whenever biometric changes
    ever(biometricEnabled, (value) {
      if (Get.isRegistered<AccountController>()) {
        final accountController = Get.find<AccountController>();
        accountController.securityMethod.value = value ? 'Fingerprint' : 'None';
      }
    });
  }

  void changePassword() {
    Get.defaultDialog(
      title: 'Change Password',
      middleText: 'Password change functionality will be implemented here',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }
  
  void changePasscode() {
    Get.defaultDialog(
      title: 'Change Passcode',
      middleText: 'Passcode change functionality will be implemented here',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }
  
  void openSupport() {
    Get.defaultDialog(
      title: 'Support',
      middleText: 'Contact support at support@mapped.com',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }
  
  void saveSettings() {
    Get.snackbar(
      'Success',
      'Security settings saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF09FACA),
      colorText: Color(0xFF1A1D29),
      duration: Duration(seconds: 2),
    );
  }

  void toggleBiometric(bool value) {
    biometricEnabled.value = value;
  }
}