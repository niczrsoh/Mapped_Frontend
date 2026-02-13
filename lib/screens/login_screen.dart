import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/login_controller.dart';
import 'package:mapped_frontend/screens/touch_id_screen.dart';
import '../global/routes.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  // Input decoration – unchanged
  static InputDecoration _inputDecoration({
    required String hint,
    bool hasError = false,
  }) {
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00E5CC),
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
          // Background image
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
                    // Header
                    Obx(() => Text(
                          controller.isAdminMode.value
                              ? "Login as Admin"
                              : "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: controller.isAdminMode.value
                                ? Colors.white
                                : const Color(0xFF00E5CC),
                            letterSpacing: 0.5,
                          ),
                        )),
                    const SizedBox(height: 50),

                    // Email field – now stateful with its own controller
                    _EmailTextField(controller: controller),
                    const SizedBox(height: 20),

                    // Password field – stateful with its own controller
                    _PasswordTextField(controller: controller),

                    const SizedBox(height: 25),

                    // Forgot Password
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.resetPassword),
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

                    // Login button
                    _RoundedActionButton(
                      label: "Login",
                      onPressed: () => controller.login(),
                      isLoading: controller.loading.value,
                    ),

                    const SizedBox(height: 15),

                    // Biometrics button (only for user mode)
                   Obx(() => Visibility(
                      visible: !controller.isAdminMode.value,
                      child: _RoundedActionButton(
                        label: "Login with Fingerprint",
                        onPressed: () {
                          Get.to(() => const TouchIdScreen()); 
                        },
                      ),
                    )),

                    const SizedBox(height: 35),

                    // Register link
                    Obx(() => Visibility(
                          visible: !controller.isAdminMode.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Did not have an account? ",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 14),
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

                    // Admin / User toggle
                    Obx(() => InkWell(
                          onTap: () => controller.toggleMode(),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              controller.isAdminMode.value
                                  ? "User Login"
                                  : "Admin Login",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF00E5CC),
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

// -------------------- Rounded Button (unchanged) --------------------
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

// -------------------- Email TextField (FIXED) --------------------
class _EmailTextField extends StatefulWidget {
  final LoginController controller;
  const _EmailTextField({required this.controller});

  @override
  __EmailTextFieldState createState() => __EmailTextFieldState();
}

class __EmailTextFieldState extends State<_EmailTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    // Initialize with current value from controller
    _textController = TextEditingController(text: widget.controller.email.value);
    // Keep the text field in sync when controller.email changes externally
    ever(widget.controller.email, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose(); // 🔥 PREVENTS THE ERROR
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError = widget.controller.emailError.value.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: LoginScreen._inputDecoration(
              hint: 'Email',
              hasError: hasError,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              // Update reactive value and clear error while typing
              widget.controller.email.value = value;
              if (hasError) widget.controller.emailError.value = '';
            },
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.emailError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }
}

// -------------------- Password TextField (FIXED) --------------------
class _PasswordTextField extends StatefulWidget {
  final LoginController controller;
  const _PasswordTextField({required this.controller});

  @override
  __PasswordTextFieldState createState() => __PasswordTextFieldState();
}

class __PasswordTextFieldState extends State<_PasswordTextField> {
  late TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.password.value);
    ever(widget.controller.password, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose(); // 🔥 PREVENTS THE ERROR
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError = widget.controller.passwordError.value.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            obscureText: _obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: LoginScreen._inputDecoration(
              hint: 'Password',
              hasError: hasError,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            onChanged: (value) {
              widget.controller.password.value = value;
              if (hasError) widget.controller.passwordError.value = '';
            },
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.passwordError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }
}