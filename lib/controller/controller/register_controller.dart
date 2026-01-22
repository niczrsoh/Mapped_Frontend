import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final googleLoading = false.obs; // Separate loading for Google sign-in
  final error = ''.obs;
  
  final ApiService _apiService = ApiService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        'Registration successful for $userEmail. Redirecting to Login...',
        backgroundColor: const Color(0xFF00C7A7), // Match your theme color
        colorText: Colors.white,
      );
      
      // Clear form
      clearForm();
      
      // Redirect to login page
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(AppRoutes.login); 
      });
      
    } else {
      // Display the error message from the backend or network
      error.value = result['error'] ?? 'An unknown error occurred.';
    }
  }

  // Google Sign-In method
  Future<void> signInWithGoogle() async {
    try {
      googleLoading.value = true;
      error.value = '';

      // Step 1: Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled
        Get.snackbar(
          'Cancelled',
          'Google sign-in was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Step 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Step 4: Sign in to Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Step 5: Register/update user in your backend
        final backendResult = await _registerGoogleUserInBackend(user);
        
        // Show success message
        Get.snackbar(
          'Welcome! 👋',
          'Signed in successfully as ${user.displayName}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate to home/dashboard
        Get.offAllNamed(AppRoutes.home);
        
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after Google sign-in',
        );
      }
      
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth errors
      error.value = _getFirebaseErrorMessage(e);
      
      Get.snackbar(
        'Authentication Error',
        error.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Google sign-in Firebase error: $e');
      
    } catch (e) {
      // Handle other errors
      error.value = 'An unexpected error occurred: ${e.toString()}';
      
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Google sign-in error: $e');
    } finally {
      googleLoading.value = false;
    }
  }

  // Helper method to register Google user in your backend
  Future<Map<String, dynamic>> _registerGoogleUserInBackend(User user) async {
    try {
      final userData = {
        'firebaseUid': user.uid,
        'name': user.displayName ?? 'Google User',
        'email': user.email,
        'avatar': user.photoURL,
        'provider': 'google',
        'phone': user.phoneNumber,
      };
      
      return await _apiService.registerGoogleUser(userData: userData);
      
    } catch (e) {
      print('Backend registration failed: $e');
      return {'success': false, 'error': 'Backend registration failed'};
    }
  }

  // Helper to get Firebase error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Account already exists with different sign-in method.';
      case 'invalid-credential':
        return 'Invalid authentication credentials.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with these credentials.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'provider-already-linked':
        return 'Provider is already linked to this account.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Clear form fields
  void clearForm() {
    fullName.value = '';
    email.value = '';
    password.value = '';
    passwordConfirmation.value = '';
  }

  // Navigate to login page
  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }
}