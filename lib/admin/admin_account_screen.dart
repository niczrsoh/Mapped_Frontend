import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/admin/admin_controller.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming you have a way to get the current admin's data, 
    // perhaps from the controller or a shared preference.
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Admin Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D2D),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[800],
                      // Added safety check for empty strings to avoid FormatException
                      backgroundImage: const AssetImage('assets/images/user.png'),
                      foregroundImage: (controller.reportedPosts.isNotEmpty && 
                                        controller.reportedPosts[0].authorImage != null)
                          ? NetworkImage("https://mapped-backend-node-js-1.onrender.com/api/${controller.reportedPosts[0].authorImage}")
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.adminName.value.isEmpty ? "Loading..." : controller.adminName.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        const Text(
                          "System Administrator",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C7A7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.security, color: Color(0xFF00C7A7), size: 14),
                              SizedBox(width: 5),
                              Text(
                                "ADMIN",
                                style: TextStyle(
                                  color: Color(0xFF00C7A7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              GestureDetector(
                onTap: () => controller.logout(), // Calls the logout method
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B1A1D), 
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row( // Removed 'const' here
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [ // Keep 'const' only for static widgets
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}