import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/admin/admin_account_screen.dart';
import 'package:mapped_frontend/admin/admin_screen.dart';

class AdminMainScreen extends StatelessWidget {
  AdminMainScreen({super.key});

  final RxInt _currentIndex = 0.obs;

  final List<Widget> _screens = [
    AdminManageUsersScreen(), // The content screen below
    const AdminAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: Obx(() => _screens[_currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1D2D),
          selectedItemColor: const Color(0xFF00C7A7),
          unselectedItemColor: Colors.white70,
          currentIndex: _currentIndex.value,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => _currentIndex.value = index,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.security),
              label: 'admin_main_nav_report'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: 'admin_main_nav_account'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
