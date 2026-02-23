import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global/routes.dart';

class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  final RxBool loading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString formError = ''.obs;
  final RxBool isAdminMode = false.obs;
  
  // 🔥 Reactive name to display on the Touch ID Screen
  final RxString storedName = ''.obs;
  var isAuthenticating = false.obs;

  final ApiService _apiService = ApiService();
  final LocalAuthentication _auth = LocalAuthentication();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final RxString googleName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredName();
  }

  /// Loads the name from local storage to display "Welcome back, [Name]"
  Future<void> _loadStoredName() async {
    final prefs = await SharedPreferences.getInstance();
    storedName.value = prefs.getString('user_name') ?? '';
  }

  void toggleMode() {
    isAdminMode.value = !isAdminMode.value;
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }

  // --- VALIDATION LOGIC ---
  bool validateEmail() {
    emailError.value = '';
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
    if (!isEmailValid) { formError.value = emailError.value; return false; }
    if (!isPasswordValid) { formError.value = passwordError.value; return false; }
    return true;
  }

  Future<void> loginWithBiometrics() async {
    try {
      isAuthenticating.value = true;

      // 1. Hardware & Biometric Verification
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      if (!isSupported || !canCheck) {
        Get.snackbar('Security', 'Biometrics not supported or registered.');
        return;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan fingerprint to log in with Google',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (authenticated) {
        // 2. Get Google Data
        GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        googleUser ??= await _googleSignIn.signIn();

        if (googleUser == null) return;

        final result = await _apiService.registerUserWithGoogle(
          uid: googleUser.id,
          email: googleUser.email,
          name: googleUser.displayName ?? '',
          photoUrl: googleUser.photoUrl,
        );

        if (result['success'] == true) {
          final responseData = result['data'];
          final String actualRole = responseData['role'] ?? 'trainee';
          final String id = responseData['user']['id'];

          // 4. Persistence (Sync with SharedPreferences)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', id);
          await prefs.setString('user_name', googleUser.displayName ?? '');
          await prefs.setString('user_email', googleUser.email);
          await prefs.setString('user_role', actualRole);
          if (result['token'] != null) await prefs.setString('auth_token', result['token']);

          // 5. Update UserController State
          final userController = Get.find<UserController>();
          userController.userId.value = id;
          userController.userData.assignAll({
            'name': googleUser.displayName ?? 'User',
            'email': googleUser.email,
            'avatar': googleUser.photoUrl ?? '',
            'role': actualRole,
          });

          Get.snackbar('Success', 'Welcome, ${googleUser.displayName}',
              backgroundColor: const Color(0xFF00C7A7), colorText: Colors.white);

          if (actualRole == 'admin') {
            Get.offAllNamed(AppRoutes.adminReport);
          } else {
            Get.offAllNamed(AppRoutes.main);
          }
        } else {
          Get.snackbar('Error', result['error'] ?? 'Backend sync failed');
        }
      }
    } catch (e) {
      debugPrint("Biometric Login Error: $e");
      Get.snackbar('Error', 'Authentication failed');
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> login() async {
    if (!validateForm()) return;

    loading.value = true;
    formError.value = ''; // Clear any previous validation errors

    try {
      final result = await _apiService.loginUser(
        email: email.value.trim(),
        password: password.value,
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        final String actualRole = responseData['user']?['role'] ?? 'trainee';

        if (isAdminMode.value && actualRole != 'admin') {
          loading.value = false;
          Get.snackbar(
            'Access Denied',
            'You do not have Admin privileges.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
          );
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
        storedName.value = name;

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
        // Show snackbar with the error message from API
        Get.snackbar(
          'Login Failed',
          result['msg'] ?? 'Invalid credentials',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Connection Error',
        'Failed to connect. Please check your internet.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
    }
  }

  void onEmailChanged(String value) {
    email.value = value;
    if (emailError.value.isNotEmpty || formError.value.isNotEmpty) validateEmail();
  }

  void onPasswordChanged(String value) {
    password.value = value;
    if (passwordError.value.isNotEmpty || formError.value.isNotEmpty) validatePassword();
  }

  void clearAll() {
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }
}