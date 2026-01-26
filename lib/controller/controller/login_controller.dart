import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global/routes.dart';

class LoginController extends GetxController {
  // Change from username to email to match your backend
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool loading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString formError = ''.obs;
  
  final ApiService _apiService = ApiService();

  // Validation methods
  bool validateEmail() {
    emailError.value = '';
    
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
      multiLine: false,
    );
    
    if (!emailRegex.hasMatch(email.value)) {
      emailError.value = 'Please enter a valid email address';
      return false;
    }
    
    return true;
  }
  
  bool validatePassword() {
    passwordError.value = '';
    
    if (password.value.isEmpty) {
      passwordError.value = 'Password is required';
      return false;
    }
    
    if (password.value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return false;
    }
    
    return true;
  }
  
  bool validateForm() {
    formError.value = '';
    
    final isEmailValid = validateEmail();
    final isPasswordValid = validatePassword();
    
    if (!isEmailValid && emailError.value.isNotEmpty) {
      formError.value = emailError.value;
      return false;
    }
    
    if (!isPasswordValid && passwordError.value.isNotEmpty) {
      formError.value = passwordError.value;
      return false;
    }
    
    return isEmailValid && isPasswordValid;
  }

  // Login method with validation
  Future<void> login() async {
    // Clear all errors
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
    
    // Validate form
    if (!validateForm()) {
      return;
    }
    
    loading.value = true;
    
    try {
      final result = await _apiService.loginUser(
        email: email.value.trim(),
        password: password.value,
      );
      
      loading.value = false;
      
      if (result['success']) {
        final responseData = result['data'];
        
        // Store user data including _id in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        
        // Store user ID (from your MongoDB document - _id)
        if (responseData['user']['id'] != null) {
          await prefs.setString('user_id', responseData['user']['id']);
          print('User ID stored: ${responseData['user']['id']}');
        }
        
        // Store other user data
        await prefs.setString('user_name', responseData['name'] ?? '');
        await prefs.setString('user_email', responseData['email'] ?? '');
        await prefs.setString('user_avatar', responseData['avatar'] ?? '');
        await prefs.setString('user_role', responseData['role'] ?? 'trainee');
        
        // Clear fields on success
        email.value = '';
        password.value = '';
        
        Get.snackbar(
          'Success! 🎉',
          'Login successful!',
          backgroundColor: const Color(0xFF00C7A7),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to main screen
        Get.offAllNamed(AppRoutes.main);
        
      } else {
        final String errorMsg = result['error'] ?? 'Login failed';
        
        // Check for common error messages from backend
        if (errorMsg.toLowerCase().contains('invalid credentials') ||
            errorMsg.toLowerCase().contains('incorrect password') ||
            errorMsg.toLowerCase().contains('user not found')) {
          formError.value = 'Invalid email or password';
        } else if (errorMsg.toLowerCase().contains('email not verified')) {
          formError.value = 'Please verify your email first';
        } else if (errorMsg.toLowerCase().contains('account locked')) {
          formError.value = 'Account is temporarily locked. Try again later.';
        } else if (errorMsg.toLowerCase().contains('too many attempts')) {
          formError.value = 'Too many login attempts. Please wait.';
        } else {
          formError.value = errorMsg;
        }
        
        if (formError.value.isNotEmpty) {
          Get.snackbar(
            'Login Failed',
            formError.value,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
      
    } catch (e) {
      loading.value = false;
      
      // Handle specific exceptions
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network is unreachable')) {
        formError.value = 'Network error. Please check your connection.';
      } else if (e.toString().contains('TimeoutException')) {
        formError.value = 'Request timed out. Please try again.';
      } else {
        formError.value = 'An unexpected error occurred. Please try again.';
      }
      
      print('Login error: $e');
      
      Get.snackbar(
        'Error',
        formError.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool get isFormValid {
    return email.value.isNotEmpty && 
          password.value.isNotEmpty &&
          emailError.value.isEmpty &&
          passwordError.value.isEmpty &&
          formError.value.isEmpty;
  }
  
  // Real-time validation as user types
  void onEmailChanged(String value) {
    email.value = value;
    if (emailError.value.isNotEmpty || formError.value.isNotEmpty) {
      validateEmail();
    }
  }
  
  void onPasswordChanged(String value) {
    password.value = value;
    if (passwordError.value.isNotEmpty || formError.value.isNotEmpty) {
      validatePassword();
    }
  }
  
  // Clear all fields and errors
  void clearAll() {
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }
  
  // Get stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}