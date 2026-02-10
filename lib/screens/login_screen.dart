import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/controller/controller/login_controller.dart';
import '../global/routes.dart';
import 'package:google_fonts/google_fonts.dart';

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
        borderSide: BorderSide(color: hasError ? Colors.redAccent : const Color(0xFF00C7A7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: hasError ? Colors.redAccent : const Color(0xFF00C7A7), width: 1),
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginBg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.60))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Header
                    Obx(() => Text(
                      controller.isAdminMode.value ? "ADMIN ACCESS" : "USER LOGIN",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                    const SizedBox(height: 40),

                    _EmailTextField(controller: controller),
                    const SizedBox(height: 12),
                    _PasswordTextField(controller: controller),

                    const SizedBox(height: 20),

                    // Main Login Button
                    Obx(() => Center(
                      child: SizedBox(
                        width: size.width * 0.68,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          onPressed: controller.loading.value ? null : () => controller.login(),
                          child: controller.loading.value
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  controller.isAdminMode.value ? "LOGIN AS ADMIN" : "LOGIN",
                                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 10),
                    
                    Obx(() => Visibility(
                      // Only show if NOT in admin mode AND the device supports biometrics
                      visible: !controller.isAdminMode.value && controller.canCheckBiometrics.value,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20), // Spacing from the login button
                          child: SizedBox(
                            width: size.width * 0.68,
                            height: 52,
                            child: OutlinedButton.icon( // Use .icon for a better look
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              // Call the logic directly from the controller
                              onPressed: () => controller.loginWithBiometrics(), 
                              icon: const Icon(Icons.fingerprint, color: Color(0xFF00C7A7)),
                              label: const Text(
                                'Login with Fingerprint',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 20),

                    // Register Link (Only shows in User mode)
                    Obx(() => Visibility(
                      visible: !controller.isAdminMode.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('New here? ', style: TextStyle(color: Colors.white70)),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text('Register', style: TextStyle(color: Color(0xDE00FAFE), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 40),

                    // THE TOGGLE LINK
                    Center(
                      child: TextButton(
                        onPressed: () => controller.toggleMode(),
                        child: Obx(() => Text(
                          controller.isAdminMode.value ? 'Switch to User Login' : 'Admin Login',
                          style: const TextStyle(color: Color(0xFF00C7A7), fontSize: 16, fontWeight: FontWeight.bold),
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

// --- Sub-widgets for Email/Password stay exactly as you wrote them ---
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