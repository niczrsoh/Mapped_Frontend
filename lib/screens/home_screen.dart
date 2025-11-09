import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller/controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapped Home')),
      body: Center(
        child: Obx(() {
          if (controller.loading.value) {
            return const CircularProgressIndicator();
          }
          if (controller.error.isNotEmpty) {
            return Text('Error: ${controller.error}');
          }
          final msg = controller.sample.value?.message ?? 'Tap to load';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(msg),
              const SizedBox(height: 12),
              ElevatedButton(
              onPressed: () {
                controller.insert(
                  title: 'New Title',
                  content: 'Inserted from Flutter!',
                );
              },
              child: const Text('Insert Sample'),
            ),
            ],
          );
        }),
      ),
    );
  }
}