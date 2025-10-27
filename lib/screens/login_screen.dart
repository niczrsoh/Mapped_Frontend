import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (v) => controller.username.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (v) => controller.password.value = v,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: controller.loading.value ? null : controller.login,
                  child: controller.loading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                )),
            const SizedBox(height: 12),
            Obx(() => Text(
                  controller.error.value,
                  style: const TextStyle(color: Colors.red),
                )),
          ],
        ),
      ),
    );
  }
}