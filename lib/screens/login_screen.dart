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
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    void goToReset() {
      // Debug print so developer can see the tap in the console
      // and confirm the onPressed handler is firing.
      // This will also perform the navigation using GetX routes.
      // If this doesn't run, the issue is that the button isn't receiving taps.
      // Use `flutter run` to view the output.
      // Example log: "Navigating to reset password"
      // ignore: avoid_print
      print('Navigating to reset password');
      Get.toNamed(AppRoutes.resetPassword);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background image or fallback gradient
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

          // dark overlay (slightly stronger so the background image reads more transparent)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.60)),
          ),

          // Title pinned to specified coordinates per design
          Positioned(
            top: 142.0,
            left: (size.width - 196.0) / 2,
            child: SizedBox(
              width: 196.0,
              height: 36.0,
              child: Opacity(
                opacity: 1.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome Back!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // content: top / middle / bottom sections so the middle (fields) is centered
          SafeArea(
            child: SingleChildScrollView(
              // reduce top/bottom padding so the title sits slightly higher
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.vertical -
                      48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // (Title moved to top overlay; kept spacing and form positions unchanged)

                    // extra gap between title and form
                    const SizedBox(height: 24),

                    // Middle: email & password (this block stays centered vertically)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: -0.41,
                          ),
                          cursorColor: const Color(0xFF00C7A7),
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) => controller.username.value = v,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: -0.41,
                          ),
                          cursorColor: const Color(0xFF00C7A7),
                          decoration: _inputDecoration('Password'),
                          obscureText: true,
                          onChanged: (v) => controller.password.value = v,
                        ),
                        const SizedBox(height: 12),

                        // Centered Forgot Password
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

                        // Buttons immediately below the forgot-password (reduced spacing)
                        const SizedBox(height: 6),

                        Obx(
                          () => Center(
                            child: SizedBox(
                              // match fingerprint button width/height for consistent sizing
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
                                onPressed: controller.loading.value
                                    ? null
                                    : controller.login,
                                child: controller.loading.value
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Center(
                          child: SizedBox(
                            // slightly wider/taller so the full label fits on one line
                            width: size.width * 0.68,
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black26),
                                shape: RoundedRectangleBorder(
                                  // match the login button's larger radius for consistent visuals
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () => Get.toNamed(AppRoutes.touchId),
                              child: Center(
                                child: Text(
                                  'Login with Fingerprint',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    // let the system choose line height so multi-line text centers better
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Small register row directly under fingerprint button
                        const SizedBox(height: 6),
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
