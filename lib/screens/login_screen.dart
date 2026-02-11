import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/login_controller.dart';
import '../global/routes.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  static InputDecoration _inputDecoration({required String hint, bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- DYNAMIC BACKGROUND IMAGE ---
          Obx(() => Positioned.fill(
                child: Image.asset(
                  controller.isAdminMode.value 
                      ? 'assets/images/adminBg.jpg' // Second Image Layout
                      : 'assets/images/loginBg.jpg', // First Image Layout
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.black),
                ),
              )),
          
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- DYNAMIC HEADER ---
                    Obx(() => Text(
                      controller.isAdminMode.value ? "ADMIN ACCESS" : "USER LOGIN",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: controller.isAdminMode.value ? Colors.redAccent : Colors.white,
                        letterSpacing: 1.2
                      ),
                    )),
                    const SizedBox(height: 40),

                    _EmailTextField(controller: controller),
                    const SizedBox(height: 16),
                    _PasswordTextField(controller: controller),

                    const SizedBox(height: 30),

                    // --- DYNAMIC LOGIN BUTTON ---
                    Obx(() => Center(
                      child: SizedBox(
                        width: size.width * 0.75,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isAdminMode.value 
                                ? Colors.redAccent 
                                : Colors.white,
                            foregroundColor: controller.isAdminMode.value 
                                ? Colors.white 
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            elevation: 5,
                          ),
                          onPressed: controller.loading.value ? null : () => controller.login(),
                          child: controller.loading.value
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  controller.isAdminMode.value ? "PROCEED TO ADMIN" : "LOGIN",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 15),
                    
                    // --- FINGERPRINT (Only for User) ---
                    Obx(() => Visibility(
                      visible: !controller.isAdminMode.value && controller.canCheckBiometrics.value,
                      child: Column(
                        children: [
                          const Text("OR", style: TextStyle(color: Colors.white38)),
                          IconButton(
                            icon: const Icon(Icons.fingerprint, size: 55, color: Color(0xFF00C7A7)),
                            onPressed: () => controller.loginWithBiometrics(),
                          ),
                          const Text("Biometric Login", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    )),

                    const SizedBox(height: 25),

                    // --- REGISTER LINK (Hidden in Admin) ---
                    Obx(() => Visibility(
                      visible: !controller.isAdminMode.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('New here? ', style: TextStyle(color: Colors.white70)),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text('Register', 
                              style: TextStyle(color: Color(0xFF00C7A7), fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 40),

                    // --- TOGGLE SWITCH ---
                    Center(
                      child: TextButton(
                        onPressed: () => controller.toggleMode(),
                        child: Obx(() => Text(
                          controller.isAdminMode.value ? 'Switch to User Login' : 'Admin Login',
                          style: const TextStyle(
                            color: Colors.white54, 
                            fontSize: 14, 
                            decoration: TextDecoration.underline
                          ),
                        )),
                      ),
                    ),
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

// --- Text Field Sub-widgets ---

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
            hint: 'Email Address',
            hasError: controller.emailError.value.isNotEmpty,
          ),
          onChanged: controller.onEmailChanged,
        ),
        if (controller.emailError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(controller.emailError.value, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
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
            hasError: widget.controller.passwordError.value.isNotEmpty,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          onChanged: widget.controller.onPasswordChanged,
        ),
        if (widget.controller.passwordError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(widget.controller.passwordError.value, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
      ],
    ));
  }
}