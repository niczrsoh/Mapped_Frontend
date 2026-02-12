import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global/routes.dart';

class LoginController extends GetxController {
  // 🔥 No TextEditingController fields – only reactive strings
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  final RxBool loading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString formError = ''.obs;
  final RxBool isAdminMode = false.obs;
  final RxBool canCheckBiometrics = false.obs;

  final ApiService _apiService = ApiService();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _checkBiometricSupport(); // still needed
  }

  // 🔥 No onClose – nothing to dispose

  /// Switches between Admin and User login modes and clears all inputs
  void toggleMode() {
    isAdminMode.value = !isAdminMode.value;

    // ✅ Clear only the reactive values – controllers are handled in widgets
    email.value = '';
    password.value = '';

    // ✅ Clear all error messages
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }

  // --- VALIDATION LOGIC (unchanged, works with email.value / password.value) ---
  bool validateEmail() {
    emailError.value = '';
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
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

    if (!isEmailValid) {
      formError.value = emailError.value;
      return false;
    }
    if (!isPasswordValid) {
      formError.value = passwordError.value;
      return false;
    }
    return true;
  }

  // --- BIOMETRIC LOGIC (unchanged) ---
  Future<void> _checkBiometricSupport() async {
    bool canCheck = await _auth.canCheckBiometrics;
    bool isSupported = await _auth.isDeviceSupported();
    canCheckBiometrics.value = canCheck && isSupported;
  }

  Future<void> loginWithBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedUserId = prefs.getString('user_id');

      if (savedUserId == null || savedUserId.isEmpty) {
        Get.snackbar(
          'Manual Login Required',
          'Please log in with your email and password first.',
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
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        String role = prefs.getString('user_role') ?? 'trainee';
        Get.snackbar('Welcome Back!', 'Login successful',
            backgroundColor: const Color(0xFF00C7A7), colorText: Colors.white);

        if (role == 'admin') {
          Get.offAllNamed(AppRoutes.adminReport);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Authentication failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- MAIN LOGIN LOGIC (uses email.value / password.value directly) ---
  Future<void> login() async {
    if (!validateForm()) return;
    loading.value = true;
    formError.value = '';

    try {
      final result = await _apiService.loginUser(
        email: email.value.trim(),   // ✅ no controller needed
        password: password.value,
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        final String actualRole = responseData['user']?['role'] ?? 'trainee';

        // Role enforcement
        if (isAdminMode.value && actualRole != 'admin') {
          loading.value = false;
          formError.value = 'Access denied. You do not have Admin privileges.';
          return;
        }

        if (!isAdminMode.value && actualRole == 'admin') {
          loading.value = false;
          formError.value = 'Admins must use the Admin Login toggle.';
          return;
        }

        final prefs = await SharedPreferences.getInstance();

        String id = responseData['user']?['id'] ?? '';
        String name = responseData['user']?['name'] ?? '';
        String emailAddr = responseData['user']?['email'] ?? '';

        await prefs.setString('user_id', id);
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', emailAddr);
        await prefs.setString('user_role', actualRole);

        if (result['token'] != null) {
          await prefs.setString('auth_token', result['token']);
        }

        final userController = Get.find<UserController>();
        userController.userId.value = id;
        await userController.fetchUserProfile();

        loading.value = false;
        clearAll();

        if (actualRole == 'admin') {
          Get.offAllNamed(AppRoutes.adminReport);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      } else {
        loading.value = false;
        formError.value = result['msg'] ?? 'Login failed';
      }
    } catch (e) {
      loading.value = false;
      formError.value = 'Connection failed. Please check your server.';
    }
  }

  // --- UI HELPER METHODS (update reactive values) ---
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

  // ✅ Clears reactive values and errors – no controllers to clear
  void clearAll() {
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }
}