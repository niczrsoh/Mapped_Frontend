import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/login_controller.dart';
import '../global/routes.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  // Updated to match the specific thin neon border and capsule shape in image_aa60d9.png
  static InputDecoration _inputDecoration({required String hint, bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.9), 
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      
      // Capsule shape with thin neon cyan border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30), 
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00E5CC), // Neon Cyan
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00E5CC),
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dynamic Background
          Obx(() => Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    controller.isAdminMode.value
                        ? 'assets/images/loginBg.jpg'
                        : 'assets/images/loginBg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Updated Header to match image_aa6591.png (Neon Cyan "User Login")
                    Obx(() => Text(
                          controller.isAdminMode.value ? "Login as Admin" : "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: controller.isAdminMode.value 
                                ? Colors.white 
                                : const Color(0xFF00E5CC), // Matching Cyan
                            letterSpacing: 0.5,
                          ),
                        )),
                    const SizedBox(height: 50),

                    // Inputs matching image_aa60d9.png
                    _EmailTextField(controller: controller),
                    const SizedBox(height: 20),
                    _PasswordTextField(controller: controller),

                    const SizedBox(height: 25),

                    // Forgot Password Link
                    TextButton(
                     onPressed: () {
                        Get.toNamed(AppRoutes.resetPassword); 
                      },
                      child: Text(
                        "Forgot Password",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF00E5CC),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Main Action Buttons
                    _RoundedActionButton(
                      label: "Login",
                      onPressed: () => controller.login(),
                      isLoading: controller.loading.value,
                    ),

                    const SizedBox(height: 15),

                    Obx(() => Visibility(
                      visible: !controller.isAdminMode.value,
                      child: _RoundedActionButton(
                        label: "Login with Fingerprint",
                        onPressed: () => controller.loginWithBiometrics(),
                      ),
                    )),

                    const SizedBox(height: 35),

                    // Registration Footer
                    Obx(() => Visibility(
                          visible: !controller.isAdminMode.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Did not have an account? ",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                              ),
                              InkWell(
                                onTap: () => Get.toNamed(AppRoutes.register),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Color(0xFF00E5CC),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 15),

                        Obx(() => InkWell(
                              // This switches the mode when the text is clicked
                              onTap: () => controller.toggleMode(),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text(
                                  // Logic: If currently in Admin mode, show "User Login" to allow switching back, 
                                  // and vice versa.
                                  controller.isAdminMode.value ? "User Login" : "Admin Login",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF00E5CC), // Neon Cyan matching your images
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )),

                        const SizedBox(height: 15),
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

// Reusable White Rounded Button component
class _RoundedActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _RoundedActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
      ),
    );
  }
}

class _EmailTextField extends StatelessWidget {
  final LoginController controller;
  const _EmailTextField({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: LoginScreen._inputDecoration(
                hint: 'Email', 
                hasError: controller.emailError.value.isNotEmpty
              ),
              onChanged: controller.onEmailChanged,
            ),
          ],
        ));
  }
}

class _PasswordTextField extends StatefulWidget {
  final LoginController controller;
  const _PasswordTextField({required this.controller});
  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              decoration: LoginScreen._inputDecoration(
                hint: 'Password', 
                hasError: widget.controller.passwordError.value.isNotEmpty
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20), 
                  onPressed: () => setState(() => _obscure = !_obscure)
                ),
              ),
              onChanged: widget.controller.onPasswordChanged,
            ),
          ],
        ));
  }
}