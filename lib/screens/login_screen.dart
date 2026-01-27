import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller/login_controller.dart';
import '../global/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  // Make this method static so it can be accessed from state classes
  static InputDecoration _inputDecoration({
    required String hint,
    bool hasError = false,
  }) {
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
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

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
            child: Container(color: Colors.black.withOpacity(0.60)),
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

                    // Middle: email & password
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field with Validation
                        _EmailTextField(controller: controller),
                        const SizedBox(height: 12),
                        
                        // Password Field with Validation
                        _PasswordTextField(controller: controller),

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

                        // Login Button - Using MediaQuery for responsive width
                        Obx(() => Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.68,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: controller.loading.value ? null : () {
                                // Clear any previous errors
                                controller.emailError.value = '';
                                controller.passwordError.value = '';
                                
                                // Validate form first
                                if (controller.validateForm()) {
                                  controller.login();
                                }
                              },
                              child: controller.loading.value
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
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

                        // Fingerprint Button - Using MediaQuery for responsive width
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.68,
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

// Email TextField as a StatefulWidget
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
    _textController = TextEditingController(text: widget.controller.email.value);
    
    // Listen to controller email changes
    ever(widget.controller.email, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError = widget.controller.emailError.value.isNotEmpty;
          
          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: -0.41,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: LoginScreen._inputDecoration(
              hint: 'Email',
              hasError: hasError,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              widget.controller.onEmailChanged(value);
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.emailError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.emailError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.emailError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// Password TextField as a StatefulWidget
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
    
    // Listen to controller password changes
    ever(widget.controller.password, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError = widget.controller.passwordError.value.isNotEmpty;
          
          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: -0.41,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: InputDecoration(
              hintText: 'Password',
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
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            onChanged: (value) {
              widget.controller.onPasswordChanged(value);
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.passwordError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.passwordError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.passwordError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}