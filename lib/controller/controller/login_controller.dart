import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/routes.dart';

class LoginController extends GetxController {
  // 1. The Gatekeeper (Form Key)
  final formKey = GlobalKey<FormState>();

  // 2. Controllers to read text
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool loading = false.obs;

  void login() async {
    // 3. VALIDATION CHECK
    // This checks if the TextFormFields are empty.
    // If they are empty, the UI turns red, and this function STOPS here.
    if (!formKey.currentState!.validate()) {
      return; 
    }

    loading.value = true;

    // 4. SIMULATE NETWORK CALL (Dummy Data)
    // Instead of calling a real server, we wait 2 seconds.
    await Future.delayed(const Duration(seconds: 2));

    // 5. Mock Success Logic
    loading.value = false;
    
    Get.snackbar(
      "Success", 
      "Login Verified (Simulation)", 
      backgroundColor: const Color(0xFF00C7A7), 
      colorText: Colors.white
    );
    
    // Navigate to Home
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}