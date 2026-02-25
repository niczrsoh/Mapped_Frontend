import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/global/routes.dart';

class ResetPasswordController extends GetxController {
  // Text Editing Controllers for UI fields
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final errorMessage = "".obs;

  final String baseUrl =
      "https://mapped-backend-node-js.onrender.com/api/users";

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();
    if (!_validateEmail(email)) return;

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Move to the OTP input screen (CheckMail)
        Get.toNamed(AppRoutes.checkMail, arguments: email);
      } else {
        errorMessage.value =
            data['msg'] ?? "reset_pwd_ctrl_error_send_failed".tr();
      }
    } catch (e) {
      errorMessage.value = "reset_pwd_ctrl_error_connection".tr();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final email = Get.arguments;
    final otp = otpController.text.trim();

    // Changed from 6 to 4 to match your new backend logic
    if (otp.length < 4) {
      errorMessage.value = "verify_code_error_incomplete".tr();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // SUCCESS: Move to next screen (Replace with your route)
        // Get.toNamed(AppRoutes.newPassword, arguments: {'email': email, 'otp': otp});
        Get.toNamed(
          AppRoutes.createNewPassword,
          arguments: {'email': email, 'otp': otp},
        );
        Get.snackbar("success".tr(), "verify_code_success_verified".tr());
      } else {
        errorMessage.value = data['msg'] ?? "verify_code_error_invalid".tr();
      }
    } catch (e) {
      errorMessage.value = "verify_code_error_verification_failed".tr();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = Get.arguments;
    final otp = otpController.text.trim();
    final newPass = newPasswordController.text.trim();

    if (newPass.length < 8) {
      errorMessage.value = "reset_pwd_ctrl_error_password_length".tr();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPass}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Password changed! Go back to login
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar("success".tr(), "reset_pwd_ctrl_success_reset".tr());
      } else {
        errorMessage.value =
            data['msg'] ?? "reset_pwd_ctrl_error_reset_failed".tr();
      }
    } catch (e) {
      errorMessage.value = "reset_pwd_ctrl_error_update_failed".tr();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper validation
  bool _validateEmail(String email) {
    if (email.isEmpty) return false;
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = "reset_pwd_ctrl_error_email_invalid".tr();
      return false;
    }
    return true;
  }
}
