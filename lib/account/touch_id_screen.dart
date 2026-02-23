import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/controller/controller/login_controller.dart';

class TouchIdScreen extends StatefulWidget {
  const TouchIdScreen({super.key});

  @override
  State<TouchIdScreen> createState() => _TouchIdScreenState();
}

class _TouchIdScreenState extends State<TouchIdScreen> {
  final LoginController controller = Get.find<LoginController>();
  bool _isLoading = false; // Local loading state

  Future<void> _handleBiometricLogin() async {
    if (_isLoading) return; // Prevent double taps
    setState(() => _isLoading = true);
    try {
      await controller.loginWithBiometrics();
      // After successful login, you might want to navigate away
      // The controller should handle navigation or error messages
    } catch (e) {
      // Optionally show a snackbar or dialog
      Get.snackbar('Error', 'Biometric authentication failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1219),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              color: Colors.teal,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              "Biometric Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Please use your fingerprint or face to continue secure access.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 60),

            // Biometric button with local loading state
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleBiometricLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.teal.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(
                  _isLoading ? "Authenticating..." : "Login with Touch ID",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Back to manual login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: const Text("Use Email & Password instead"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}