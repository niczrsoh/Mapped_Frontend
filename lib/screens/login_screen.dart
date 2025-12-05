import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller/login_controller.dart';
import '../global/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.white10,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C7A7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C7A7), width: 1),
    ),
    // Red border when validation fails
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    void goToReset() {
      Get.toNamed(AppRoutes.resetPassword);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginBg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E1E1E), Color(0xFF2B2B2B)],
                  ),
                ),
              ),
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.60)),
          ),

          // Title
          Positioned(
            top: 142.0,
            left: 0,   // Pin to left edge
            right: 0,  // Pin to right edge
            child: Center( // This automatically centers the text
              child: Text(
                'Welcome Back!',
                maxLines: 1, 
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.vertical - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // --- FORM START ---
                    Form(
                      key: controller.formKey, // REQUIRED for validation to work
                      child: Column(
                        children: [
                          // EMAIL FIELD
                          TextFormField(
                            controller: controller.emailController,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            cursorColor: const Color(0xFF00C7A7),
                            decoration: _inputDecoration('Email'),
                            keyboardType: TextInputType.emailAddress,
                            // Validation Logic
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // PASSWORD FIELD
                          TextFormField(
                            controller: controller.passwordController,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            cursorColor: const Color(0xFF00C7A7),
                            decoration: _inputDecoration('Password'),
                            obscureText: true,
                            // Validation Logic
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              //if (value.length < 6) {
                               // return 'Password must be at least 6 chars';
                              //}
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    // --- FORM END ---

                    const SizedBox(height: 12),

                    // Forgot Password
                    Center(
                      child: TextButton(
                        onPressed: goToReset,
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Color(0xDE00FAFE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Login Button
                    Obx(() => Center(
                      child: SizedBox(
                        width: size.width * 0.68,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: controller.loading.value ? null : controller.login,
                          child: controller.loading.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 6),

                    // Fingerprint Button
                    Center(
                      child: SizedBox(
                        width: size.width * 0.68,
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () => Get.toNamed(AppRoutes.touchId),
                          child: Text(
                            'Login with Fingerprint',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Register Link
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Did not have an account? ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Color(0xDE00FAFE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}