import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../global/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sending = false;

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

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // Do nothing when email is empty (silent return per UX request)
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    setState(() => _sending = false);

    // Navigate to check-mail confirmation screen without showing a snackbar
    Get.toNamed(AppRoutes.checkMail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // using MediaQuery only for padding where needed

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Use a solid background color per design (#141823)
          Positioned.fill(child: Container(color: const Color(0xFF141823))),

          // Back arrow and 'Login' label on the same line
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  // Navigate explicitly to the login screen instead of popping
                  onTap: () => Get.toNamed(AppRoutes.login),
                  child: Icon(
                    Icons.chevron_left,
                    color: const Color(0xFFFFEEFF),
                    size: 22,
                    semanticLabel: 'Back to Login',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Login',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFEEFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),

          // Title: Reset Password (positioned per spec)
          Positioned(
            top: 147.0,
            left: 44.0,
            child: SizedBox(
              width: 196.0,
              height: 30.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reset Password',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // Description text (positioned per spec)
          Positioned(
            top: 204.0,
            left: 44.0,
            child: SizedBox(
              width: 294.0,
              height: 122.0,
              child: Text(
                "Enter the email associated with your account and we'll send an email with instructions and passcode to reset your password.",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Email TextField (moved up closer to description)
          Positioned(
            top: 328.0,
            left: 39.0,
            child: SizedBox(
              width: 304.0,
              height: 56.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: const Color(0xFF00C7A7),
                  decoration: _inputDecoration('Email').copyWith(
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Color(0xFF00C7A7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF00C7A7),
                        width: 1,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
          ),

          // Reset Password button (moved up to sit closer to the field)
          Positioned(
            top: 392.0,
            left: 38.0,
            child: SizedBox(
              width: 303.0,
              height: 46.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: _sending ? null : _sendReset,
                child: _sending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Reset Password',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
