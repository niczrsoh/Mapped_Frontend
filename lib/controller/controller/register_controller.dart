import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/global/routes.dart';
import 'package:mapped_frontend/services/api_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController {
  // Data fields
  final fullName = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final passwordConfirmation = ''.obs;
  
  // Error fields for validation
  final RxString fullNameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString passwordConfirmationError = ''.obs;
  final RxString error = ''.obs;
  
  // State management
  final loading = false.obs;
  final googleLoading = false.obs;
  
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void onInit() {
    error.value = ''; 
    super.onInit();
  }

  // Validation methods
  bool validateFullName() {
    fullNameError.value = '';
    
    if (fullName.value.isEmpty) {
      fullNameError.value = 'Full name is required';
      return false;
    }
    
    if (fullName.value.trim().length < 2) {
      fullNameError.value = 'Full name must be at least 2 characters';
      return false;
    }
    
    return true;
  }
  
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
  
  bool validatePasswordConfirmation() {
    passwordConfirmationError.value = '';
    
    if (passwordConfirmation.value.isEmpty) {
      passwordConfirmationError.value = 'Please confirm your password';
      return false;
    }
    
    if (password.value != passwordConfirmation.value) {
      passwordConfirmationError.value = 'Passwords do not match';
      return false;
    }
    
    return true;
  }
  
  bool validateForm() {
    error.value = '';
    
    final isFullNameValid = validateFullName();
    final isEmailValid = validateEmail();
    final isPasswordValid = validatePassword();
    final isPasswordConfirmationValid = validatePasswordConfirmation();
    
    if (!isFullNameValid && fullNameError.value.isNotEmpty) {
      error.value = fullNameError.value;
      return false;
    }
    
    if (!isEmailValid && emailError.value.isNotEmpty) {
      error.value = emailError.value;
      return false;
    }
    
    if (!isPasswordValid && passwordError.value.isNotEmpty) {
      error.value = passwordError.value;
      return false;
    }
    
    if (!isPasswordConfirmationValid && passwordConfirmationError.value.isNotEmpty) {
      error.value = passwordConfirmationError.value;
      return false;
    }
    
    return isFullNameValid && isEmailValid && isPasswordValid && isPasswordConfirmationValid;
  }

  void register() async {
      // Clear all errors first
      fullNameError.value = '';
      emailError.value = '';
      passwordError.value = '';
      passwordConfirmationError.value = '';
      error.value = '';
    
      loading.value = true;
      error.value = '';

      final String userFullName = fullName.value.trim();
      final String userEmail = email.value.trim();
      final String userPassword = password.value;

      try {
        // 1. STEP ONE: Create the user in your Backend (MongoDB)
        final result = await _apiService.registerUser(
          fullName: userFullName,
          email: userEmail,
          password: userPassword,
        );

        if (result['success']) {
          
          // 2. STEP TWO: Store the user in Firebase so Reset Email works later
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: userEmail,
              password: userPassword,
            );
            // Optional: Update Firebase display name to match MongoDB
            await FirebaseAuth.instance.currentUser?.updateDisplayName(userFullName);
          } on FirebaseAuthException catch (e) {
            // If the user already exists in Firebase but not MongoDB, we handle it
            if (e.code != 'email-already-in-use') {
              print("Firebase Sync Error: ${e.message}");
            }
          }

          loading.value = false;
          error.value = '';
          
          // 3. STEP THREE: Show success dialog
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: const Color(0xFF1a1f2e),
              content: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00C7A7).withOpacity(0.2),
                      ),
                      child: const Icon(Icons.check_circle, color: Color(0xFF00C7A7), size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text('Congrats!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Your account has been\nsuccessfully created.', style: TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C7A7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Get.back();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
          
        } else {
          loading.value = false;
          error.value = result['error'] ?? 'An unknown error occurred.';
        }
      } catch (e) {
        loading.value = false;
        error.value = "An unexpected error occurred during registration.";
        print("Registration Error: $e");
      }
  }

  Future<void> registerWithGoogle() async {
    try {
      googleLoading.value = true;
      error.value = '';

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        googleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Send user data to your backend
        final result = await _apiService.registerUserWithGoogle(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          photoUrl: firebaseUser.photoURL,
        );

        googleLoading.value = false;

        if (result['success']) {
          // Store user data in SharedPreferences
          final responseData = result['data'] ?? {};
          
          final prefs = await SharedPreferences.getInstance();
          
          // Store user ID
          if (responseData['user'] != null && responseData['user']['id'] != null) {
            await prefs.setString('user_id', responseData['user']['id']);
          } else if (responseData['id'] != null) {
            await prefs.setString('user_id', responseData['id']);
          } else {
            // Fallback to Firebase UID
            await prefs.setString('user_id', firebaseUser.uid);
          }
          
          // Store other user data
          await prefs.setString('user_name', 
            responseData['name'] ?? firebaseUser.displayName ?? '');
          await prefs.setString('user_email', 
            responseData['email'] ?? firebaseUser.email ?? '');
          await prefs.setString('user_avatar', 
            responseData['avatar'] ?? firebaseUser.photoURL ?? '');
          await prefs.setString('user_role', 
            responseData['role'] ?? 'trainee');

          final userController = Get.find<UserController>();
          
          // Force clear and reload user data
          userController.userData.value = {};
          if (responseData['user'] != null && responseData['user']['id'] != null) {
            userController.userId.value = responseData['user']['id'];
          }

          await userController.fetchUserProfile();

          Get.snackbar(
            'Success! 🎉',
            'Google Sign-Up successful!',
            backgroundColor: const Color(0xFF00C7A7),
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
          
          // Navigate to home screen
          Get.offAllNamed(AppRoutes.main);
        } else {
          error.value = result['error'] ?? 'Failed to register with Google.';
        }
      } else {
        googleLoading.value = false;
        error.value = 'Google Sign-Up failed: No user data received.';
      }
    } catch (e) {
      googleLoading.value = false;
      error.value = 'Google Sign-Up failed: ${e.toString()}';
      print('Google Sign-Up Error: $e');
    }
  }

  // Clear all fields and errors
  void clearAll() {
    fullName.value = '';
    email.value = '';
    password.value = '';
    passwordConfirmation.value = '';
    
    fullNameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    passwordConfirmationError.value = '';
    error.value = '';
  }
}