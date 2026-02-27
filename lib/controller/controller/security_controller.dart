import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
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
        accountController.securityMethod.value = value
            ? 'security_ctrl_method_fingerprint'
            : 'security_ctrl_method_none';
      }
    });
  }

  void changePassword() {
    Get.defaultDialog(
      title: 'security_ctrl_dialog_pwd_title'.tr(),
      middleText: 'security_ctrl_dialog_pwd_msg'.tr(),
      textConfirm: 'ok'.tr(),
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }

  void changePasscode() {
    Get.defaultDialog(
      title: 'security_ctrl_dialog_passcode_title'.tr(),
      middleText: 'security_ctrl_dialog_passcode_msg'.tr(),
      textConfirm: 'ok'.tr(),
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }

  void openSupport() {
    Get.defaultDialog(
      title: 'security_ctrl_dialog_support_title'.tr(),
      middleText: 'security_ctrl_dialog_support_msg'.tr(),
      textConfirm: 'ok'.tr(),
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF09FACA),
      onConfirm: () => Get.back(),
    );
  }

  void saveSettings() {
    Get.snackbar(
      'success'.tr(),
      'security_ctrl_snackbar_success_msg'.tr(),
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
