import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/password/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  // Use Get.put or Get.find depending on how you navigate here
  // If navigating via Get.to(), Get.put initializes it.
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.white10,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Color(0xFF00C7A7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Color(0xFF00C7A7), width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Injecting the controller
    final ResetPasswordController controller = Get.put(ResetPasswordController());

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Container(color: const Color(0xFF141823))),

          // Back Button & Label
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFFFFEEFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'login'.tr(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFEEFF),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Header
          Positioned(
            top: 147.0,
            left: 44.0,
            child: Text(
              'reset_password_header'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: 204.0,
            left: 44.0,
            child: SizedBox(
              width: 294.0,
              child: Text(
                "reset_password_description".tr(),
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Email Input Field
          Positioned(
            top: 328.0,
            left: 39.0,
            child: SizedBox(
              width: 304.0,
              child: TextField(
                // FIXED: Using controller's emailController
                controller: controller.emailController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF00C7A7),
                decoration: _inputDecoration('email'.tr()),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),

          // Reset Button
          Positioned(
            top: 405.0,
            left: 38.0,
            child: SizedBox(
              width: 303.0,
              height: 48.0,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () => controller.sendResetEmail(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Reset Email',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  )),
            ),
          ),

          // Error Message Display
          Positioned(
            top: 470.0,
            left: 44.0,
            right: 44.0,
            child: Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
