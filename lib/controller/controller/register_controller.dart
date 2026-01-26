import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final googleLoading = false.obs;
  
  final ApiService _apiService = ApiService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
   // Google SignIn with proper constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
   );

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

   // NEW: Google Sign-Up Method
  Future<void> registerWithGoogle() async {
    try {
      googleLoading.value = true;
      error.value = '';

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        googleLoading.value = false;
        return;
      }

      // Obtain auth details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
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
          Get.snackbar(
            'Success! 🎉',
            'Google Sign-Up successful!',
            backgroundColor: const Color(0xFF00C7A7),
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
          
          // Navigate to home screen or dashboard
          Get.offAllNamed(AppRoutes.login);
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
}