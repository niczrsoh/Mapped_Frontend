import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mapped_frontend/global/routes.dart';
import '../../services/api_service.dart'; 

class RegisterController extends GetxController {
  // Data fields linked to TextFields
  final fullName = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final passwordConfirmation = ''.obs;
  
  // State management
  final loading = false.obs;
  final error = ''.obs;
  
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    error.value = ''; 
    super.onInit();
  }

  void register() async {
    // 1. Client-side Validation
    if (email.isEmpty || password.isEmpty || fullName.isEmpty || passwordConfirmation.isEmpty) {
      error.value = 'Please fill in all fields.';
      return;
    }
    
    if (password.value != passwordConfirmation.value) {
      error.value = 'Passwords do not match.';
      return;
    }
    
    // 2. Prepare and Set Loading State
    loading.value = true;
    error.value = '';

    final String userFullName = fullName.value.trim();
    final String userEmail = email.value.trim();
    final String userPassword = password.value;

    // 3. Call API Service
    final result = await _apiService.registerUser(
      fullName: userFullName,
      email: userEmail,
      password: userPassword,
    );

    // 4. Handle Result and Update UI
    loading.value = false;
    
    if (result['success']) {
      error.value = '';
      Get.snackbar(
        'Success! 🎉',
        'Registration successful for ${userEmail}. Redirecting to Login...',
        backgroundColor: const Color(0xFF00C7A7), // Match your theme color
        colorText: Colors.white,
      );
      
      // Assuming you have a route named 'login' defined in AppRoutes
      Get.offAllNamed(AppRoutes.login); 
      
    } else {
      // Display the error message from the backend or network
      error.value = result['error'] ?? 'An unknown error occurred.';
    }
  }
}