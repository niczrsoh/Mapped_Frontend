import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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

  final newPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = "".obs;

  final String baseUrl =
      "https://mapped-backend-node-js.onrender.com/api/users";

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
      emailError.value = 'login_error_email_required'.tr();
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email.value)) {
      emailError.value = 'login_error_email_invalid'.tr();
      return false;
    }
    return true;
  }

  bool validatePassword() {
    passwordError.value = '';
    if (password.value.isEmpty) {
      passwordError.value = 'login_error_password_required'.tr();
      return false;
    }
    if (password.value.length < 6) {
      passwordError.value = 'login_error_password_length'.tr();
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

  Future<void> loginWithBiometrics() async {
    try {
      isAuthenticating.value = true;

      // 1. Hardware & Biometric Verification
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      if (!isSupported || !canCheck) {
        Get.snackbar(
          'login_snackbar_security_title'.tr(),
          'login_error_biometrics_unsupported'.tr(),
        );
        return;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'login_prompt_biometric_reason'.tr(),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
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
          if (result['token'] != null)
            await prefs.setString('auth_token', result['token']);

          // 5. Update UserController State
          final userController = Get.find<UserController>();
          userController.userId.value = id;
          userController.userData.assignAll({
            'name': googleUser.displayName ?? 'User',
            'email': googleUser.email,
            'avatar': googleUser.photoUrl ?? '',
            'role': actualRole,
          });

          Get.snackbar(
            'success'.tr(),
            'login_snackbar_welcome'.tr(
              namedArgs: {'name': googleUser.displayName ?? 'User'},
            ),
            backgroundColor: const Color(0xFF00C7A7),
            colorText: Colors.white,
          );

          if (actualRole == 'admin') {
            Get.offAllNamed(AppRoutes.adminReport);
          } else {
            Get.offAllNamed(AppRoutes.main);
          }
        } else {
          Get.snackbar(
            'error'.tr(),
            result['error'] ?? 'login_error_backend_sync'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Biometric Login Error: $e");
      Get.snackbar('error'.tr(), 'login_error_auth_failed'.tr());
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = Get.arguments;
    final newPass = newPasswordController.text.trim();

    if (newPass.length < 8) {
      errorMessage.value = 'reset_pwd_ctrl_error_password_length'.tr();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'newPassword': newPass}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar('success'.tr(), 'reset_pwd_ctrl_success_reset'.tr());
      } else {
        errorMessage.value =
            data['msg'] ?? 'reset_pwd_ctrl_error_reset_failed'.tr();
      }
    } catch (e) {
      errorMessage.value = 'reset_pwd_ctrl_error_update_failed'.tr();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!validateForm()) return;

    loading.value = true;
    formError.value = '';

    final String userEmail = email.value.trim();
    final String userPassword = password.value;

    try {
      // --- 1. ADMIN LOGIN ---
      if (isAdminMode.value) {
        final result = await _apiService.loginUser(
          email: userEmail,
          password: userPassword,
        );

        if (result['success'] == true) {
          final responseData = result['data'];
          if (responseData['user']?['role'] == 'admin') {
            await _processSuccessfulLogin(result, isFirebase: false);
            Get.offAllNamed(AppRoutes.adminReport);
          } else {
            loading.value = false;
            _showError(
              'login_error_admin_denied'.tr(),
              'login_error_admin_denied'.tr(),
            );
          }
        } else {
          loading.value = false;
          _showError(
            'login_error_login_failed'.tr(),
            result['msg'] ?? 'login_error_login_failed'.tr(),
          );
        }
        return;
      }

      // --- 2. REGULAR USER LOGIN: Firebase + MongoDB Sync ---
      try {
        // Step A: Authenticate with Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: userEmail,
              password: userPassword,
            );

        final User? fbUser = userCredential.user;

        if (fbUser != null) {
          // Step B: Immediately sync this password to MongoDB using your reset-password logic
          // We use the 'userPassword' entered in the login form
          await _syncPasswordToMongo(userEmail, userPassword);

          // Step C: Now login to MongoDB to get the full User Object/Role
          final result = await _apiService.loginUser(
            email: userEmail,
            password: userPassword,
          );

          if (result['success'] == true) {
            await _processSuccessfulLogin(result, isFirebase: false);
            Get.offAllNamed(AppRoutes.main);
          } else {
            loading.value = false;
            _showError('error'.tr(), 'login_error_backend_sync'.tr());
          }
        }
      } on FirebaseAuthException catch (e) {
        loading.value = false;
        _showError(
          'login_error_login_failed'.tr(),
          e.message ?? 'login_error_auth_failed'.tr(),
        );
      }
    } catch (e) {
      loading.value = false;
      debugPrint("Login Error: $e");
      _showError('login_error_connection_failed'.tr(), 'error_network'.tr());
    }
  }

  /// New Helper to call your reset-password endpoint during login
  Future<void> _syncPasswordToMongo(String email, String newPass) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'newPassword': newPass}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        debugPrint("Sync Warning: ${data['msg']}");
      }
    } catch (e) {
      debugPrint("Password sync failed: $e");
    }
  }

  // Helper function updated to handle local Firebase data or Backend data
  Future<void> _processSuccessfulLogin(
    dynamic result, {
    required bool isFirebase,
  }) async {
    final responseData = result['data'];
    final prefs = await SharedPreferences.getInstance();

    String id = responseData['user']?['id'] ?? '';
    String name = responseData['user']?['name'] ?? '';
    String emailAddr = responseData['user']?['email'] ?? '';
    String role = responseData['user']?['role'] ?? 'trainee';

    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', emailAddr);
    await prefs.setString('user_role', role);
    storedName.value = name;

    if (result['token'] != null) {
      await prefs.setString('auth_token', result['token']);
    }

    // Update your UserController
    final userController = Get.find<UserController>();
    userController.userId.value = id;

    // Only fetch profile from MongoDB if it's an Admin or if you still store extra data there
    if (!isFirebase) {
      await userController.fetchUserProfile();
    }

    loading.value = false;
    clearAll();
  }

  void _showError(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  void onEmailChanged(String value) {
    email.value = value;
    if (emailError.value.isNotEmpty || formError.value.isNotEmpty)
      validateEmail();
  }

  void onPasswordChanged(String value) {
    password.value = value;
    if (passwordError.value.isNotEmpty || formError.value.isNotEmpty)
      validatePassword();
  }

  void clearAll() {
    email.value = '';
    password.value = '';
    emailError.value = '';
    passwordError.value = '';
    formError.value = '';
  }
}
