import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/controller/register_controller.dart';
import '../global/routes.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  InputDecoration _inputDecoration(String label) => InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.white10,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C7A7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      // keep same width/color as enabledBorder to avoid the animated thickness change
      borderSide: const BorderSide(color: Color(0xFF00C7A7), width: 1),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background image (falls back to gradient if asset missing)
          Positioned.fill(
            child: Image.asset(
              // use the project asset named registerBg (png preferred).
              // Place the image at assets/images/registerBg.png in the project.
              'assets/images/registerBg.jpg',
              fit: BoxFit.cover,
              // apply a subtle dark blend so the image appears dimmer under the overlay
              color: Colors.black.withOpacity(0.35),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(
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
          // dark overlay to increase contrast for fields (darker per design)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // logo (use asset if provided, otherwise text)
                  Center(
                    // child: Image.asset(
                    //   'assets/images/logo.png',
                    //   width: 180,
                    //   height: 80,
                    //   fit: BoxFit.contain,
                    //   errorBuilder: (context, error, stackTrace) => ShaderMask(
                    //     shaderCallback: (rect) =>
                    //         LinearGradient(
                    //           begin: Alignment.topCenter,
                    //           end: Alignment.bottomCenter,
                    //           colors: [Color(0xFF0A5848), Color(0xFF09FACA)],
                    //         ).createShader(
                    //           Rect.fromLTWH(0, 0, rect.width, rect.height),
                    //         ),
                    //     blendMode: BlendMode.srcIn,
                    //     child: Text(
                    //       'MAPPED',
                    //       style: const TextStyle(
                    //         fontFamily:
                    //             'NicoMoji', // still differrent with the figma?????
                    //         color: Colors.white,
                    //         fontSize: 48,
                    //         fontWeight: FontWeight.w700,
                    //         letterSpacing: 4,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 36),

                  TextField(
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: const Color(0xFF00C7A7),
                    decoration: _inputDecoration('Full Name'),
                    onChanged: (v) => controller.fullName.value = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: const Color(0xFF00C7A7),
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => controller.email.value = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: const Color(0xFF00C7A7),
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    onChanged: (v) => controller.password.value = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: const Color(0xFF00C7A7),
                    decoration: _inputDecoration('Password Confirmation'),
                    obscureText: true,
                    onChanged: (v) => controller.passwordConfirmation.value = v,
                  ),

                  const SizedBox(height: 20),
                  Obx(
                    () => Center(
                      child: SizedBox(
                        // make the button narrower to match the design
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50, //button height
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: controller.loading.value
                              ? null
                              : controller.register,
                          child: controller.loading.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Register',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Obx(
                      () => Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.toNamed(AppRoutes.touchId),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF00C7A7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50, //button height
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB4437),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: implement google sign up
                        },
                        child: Text(
                          'Register via Google',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
