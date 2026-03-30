import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

class ResetPasswordController extends GetxController {
  final emailController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final errorMessage = "".obs;
  final String baseUrl =
      "https://mapped-backend-node-js-ce6r.onrender.com/api/users";

  Future<void> sendResetEmail() async {
    String email = emailController.text.trim();

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      try {
        isLoading.value = true;
        errorMessage.value = "";

        final response = await http.post(
          Uri.parse('$baseUrl/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'identifier': email}),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          email = data['email'];
          emailController.text = email;
        } else {
          errorMessage.value = data['msg'] ?? "User not found.";
          isLoading.value = false;
          return;
        }
      } catch (e) {
        errorMessage.value = "Backend connection failed.";
        isLoading.value = false;
        return;
      }
    }

    if (!_validateEmail(email)) {
      // Stop loading if validation fails
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      // 1. Firebase handles the email delivery
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 3. Show Success Feedback
      Get.snackbar(
        "Success",
        "A reset link has been sent to your email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00C7A7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );

      Future.delayed(const Duration(seconds: 2), () => Get.back());
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "An error occurred";
    } catch (e) {
      errorMessage.value = "An unexpected error occurred.";
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER VALIDATION ---
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      errorMessage.value = "Please enter your email address.";
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = "Enter a valid email address.";
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
