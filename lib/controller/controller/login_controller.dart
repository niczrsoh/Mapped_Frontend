import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global/routes.dart';
import 'trainer_controller.dart';

class LoginController extends GetxController {
  // Change from username to email to match your backend
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool loading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString formError = ''.obs;
  final RxBool isAdminMode = false.obs;
  final RxBool canCheckBiometrics = false.obs;

  void toggleMode() 
  {
    isAdminMode.value = !isAdminMode.value;
    clearAll();
  }
  
  final ApiService _apiService = ApiService();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _checkBiometricSupport();
  }

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

  Future<void> _checkBiometricSupport() async {
    bool canCheck = await _auth.canCheckBiometrics;
    bool isSupported = await _auth.isDeviceSupported();
    canCheckBiometrics.value = canCheck && isSupported;
  }

  // --- BIOMETRIC LOGIN LOGIC ---
  Future<void> loginWithBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedUserId = prefs.getString('user_id');

      if (savedUserId == null || savedUserId.isEmpty) {
        Get.snackbar(
          'Manual Login Required',
          'Please log in with your email and password at least once first.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Please scan your fingerprint to log in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true, // Automatically shows system dialogs for errors
        ),
      );

      if (authenticated) {
        String role = prefs.getString('user_role') ?? 'trainee';
        
        Get.snackbar('Welcome Back!', 'Biometric login successful',
            backgroundColor: const Color(0xFF00C7A7), colorText: Colors.white);

        // Navigate based on stored role
        if (role == 'admin') {
          Get.offAllNamed(AppRoutes.adminReport);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Biometric authentication failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- TRADITIONAL LOGIN LOGIC ---
  Future<void> login() async {
    if (!validateForm()) return;
    loading.value = true;
    formError.value = '';

    try {
      final result = await _apiService.loginUser(
        email: email.value.trim(),
        password: password.value,
      );

      loading.value = false;

      if (result['success'] == true) 
      {
        final responseData = result['data'];
        
        final prefs = await SharedPreferences.getInstance();

        String newUserId = responseData['user']['id'] ?? '';

        // 1. Store Data for Persistence
        String id = responseData['user']?['id'] ?? '';
        String name = responseData['user']?['name'] ?? '';
        String emailAddr = responseData['user']?['email'] ?? '';
        String assignedRole = isAdminMode.value ? 'admin' : (responseData['user']?['role'] ?? 'trainee');

        await prefs.setString('user_id', id);
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', emailAddr);
        await prefs.setString('user_role', assignedRole);
        
        if (result['token'] != null) {
          await prefs.setString('auth_token', result['token']);
        }

        // 2. Update Global Controller
        final userController = Get.find<UserController>();
        userController.userId.value = id;
        await userController.fetchUserProfile();

        clearAll();

        // 3. Navigation
        if (assignedRole == 'admin') {
          Get.offAllNamed(AppRoutes.adminReport); 
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
        
      } else {
        formError.value = result['msg'] ?? 'Login failed';
      }
    } catch (e) {
      loading.value = false;
      formError.value = 'Connection failed. Please check your server.';
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