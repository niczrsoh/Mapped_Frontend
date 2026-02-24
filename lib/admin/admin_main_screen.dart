import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/admin/admin_account_screen.dart';
import 'package:mapped_frontend/admin/admin_screen.dart';
import 'package:mapped_frontend/admin/admin_resource.dart';


class AdminMainScreen extends StatelessWidget {
  AdminMainScreen({super.key});

  final RxInt _currentIndex = 0.obs;

  final List<Widget> _screens = [
     AdminManageUsersScreen(), // The content screen below
     AdminResource(),
    const AdminAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: Obx(() => _screens[_currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1D2D),
        selectedItemColor: const Color(0xFF00C7A7),
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex.value,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Resource'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      )),
    );
  }
}