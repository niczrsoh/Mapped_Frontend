import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/password/reset_password_controller.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final ResetPasswordController controller = Get.find<ResetPasswordController>();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Helper for consistent styling
  InputDecoration _inputStyle(String hint, bool isObscure, VoidCallback toggle) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
          onPressed: toggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00FAFE), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00FAFE), width: 2),
        ),
      );

  void _handleSubmit() {
    final newPass = controller.newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      controller.errorMessage.value = "Please fill in all fields.";
      return;
    }

    if (newPass != confirmPass) {
      controller.errorMessage.value = "Passwords do not match.";
      return;
    }

    if (newPass.length < 8) {
      controller.errorMessage.value = "Password must be at least 8 characters.";
      return;
    }

    // Call the controller function
    controller.resetPassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    Text('Login', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Create New Password',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your new password must be different from previously used password',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Password Field
              Text('Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.newPasswordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('Key-in password', _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
              ),
              const SizedBox(height: 5),
              Text('Must be at least 8 characters', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),

              const SizedBox(height: 25),

              // Confirm Password Field
              Text('Confirm', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('Key-in password confirmation', _obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }),
              ),
              const SizedBox(height: 5),
              Text('Both passwords must match', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),

              const SizedBox(height: 40),

              // Error Message
              Obx(() => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox.shrink()),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Color(0xFF141823))
                          : Text(
                              'Reset Password',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF141823),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}