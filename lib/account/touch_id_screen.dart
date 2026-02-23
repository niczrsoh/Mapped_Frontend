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
  bool _isLoading = false;

  Future<void> _handleBiometricLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await controller.loginWithBiometrics();
    } catch (e) {
      Get.snackbar('Error', 'Biometric authentication failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Radial gradient background to match the "glow" in the image center
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.1),
            radius: 0.8,
            colors: [
              Color(0xFF1A2B2F), // Lighter teal/dark center
              Color(0xFF0D1017), // Very dark blue/black edge
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Title
              const Text(
                "Touch ID",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Place and hold your finger on the\nFinger reader",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
              
              const Spacer(),

              // Fingerprint Reader Circle
              GestureDetector(
                onTap: _handleBiometricLogin,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white70)
                      : const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                          size: 45,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 100),

              // "One Moment..." Text
              Text(
                _isLoading ? "Processing..." : "One Moment...",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const Spacer(flex: 2),

              // Login with Email Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Login with Email",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}