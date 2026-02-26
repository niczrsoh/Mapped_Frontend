import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
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
            Text(
              "touch_id_title_main".tr(),
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "touch_id_msg_instruction".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 60),
            
            // --- FINGERPRINT TAP AREA ---
            Obx(() => GestureDetector(
              // Correct usage: Pass the function as a callback to onTap
              onTap: controller.isAuthenticating.value 
                  ? null 
                  : () => controller.loginWithBiometrics(),
              behavior: HitTestBehavior.opaque,
              child: Center(
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
                      ),
                    ],
                    gradient: const RadialGradient(
                      colors: [Color(0xFF2D3E40), Color(0xFF1A2226)],
                    ),
                  ),
                  child: controller.isAuthenticating.value
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        )
                      : const Icon(Icons.fingerprint, color: Colors.white, size: 70),
                ),
              ),
            )),

            const SizedBox(height: 80),

            // Back to Manual Login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("touch_id_btn_login_email".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}