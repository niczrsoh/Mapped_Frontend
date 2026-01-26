// screens/account_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/account_controller.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});
  
  final AccountController controller = Get.put(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: Obx(() {
        // Show loading indicator while fetching data
        return RefreshIndicator(
          onRefresh: controller.fetchUserProfile,
          backgroundColor: Color(0xFF1A1D29),
          color: Color(0xFF09FACA),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildGradientHeader(),
                Transform.translate(
                  offset: Offset(0, -48),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildDarkSection([
                          _MenuItem(
                            iconPath: 'assets/images/profile.png',
                            text: 'Edit profile information',
                            onTap: () {
                              // Make sure this route is defined in your GetMaterialApp
                              Get.toNamed('/profile-edit');
                            },
                          ),
                          _MenuItem(
                            iconPath: 'assets/images/notification.png',
                            text: 'Notifications',
                            badge: 'ON',
                            badgeColor: Color(0xFF09FACA),
                            onTap: () {
                              Get.toNamed('/notifications');
                            },
                          ),
                          _MenuItem(
                            iconPath: 'assets/images/logout.png',
                            text: 'Log Out',
                            onTap: () {
                              // Show confirmation dialog before logout
                              Get.defaultDialog(
                                title: "Logout",
                                middleText: "Are you sure you want to logout?",
                                textConfirm: "Yes",
                                textCancel: "No",
                                confirmTextColor: Colors.white,
                                cancelTextColor: Color(0xFF09FACA),
                                buttonColor: Color(0xFF09FACA),
                                onConfirm: controller.logout,
                              );
                            },
                          ),
                        ]),
                        SizedBox(height: 16),
                        _buildLightSection([
                          _MenuItem(
                            iconPath: 'assets/images/security.png',
                            text: 'Security',
                            badge: 'Fingerprint',
                            badgeColor: Color(0xFF09FACA),
                            isDark: false,
                            onTap: () => Get.toNamed('/security'),
                          ),
                          _MenuItem(
                            iconPath: 'assets/images/language.png',
                            text: 'Language',
                            isDark: false,
                            onTap: () => Get.toNamed('/language'),
                          ),
                        ]),
                        SizedBox(height: 16),
                        _buildDarkSection([
                          _MenuItem(
                            iconPath: 'assets/images/help.png',
                            text: 'Help & Support',
                            onTap: () => Get.toNamed('/help'),
                          ),
                          _MenuItem(
                            iconPath: 'assets/images/privacy.png',
                            text: 'Privacy policy',
                            onTap: () => Get.toNamed('/privacy'),
                          ),
                          _MenuItem(
                            iconPath: 'assets/images/about.png',
                            text: 'About Us',
                            onTap: () => Get.toNamed('/about'),
                          ),
                        ]),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, bottom: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF09FACA).withOpacity(0.6),
            Color(0xFF09FACA),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, 
                  blurRadius: 10, 
                  offset: Offset(0, 4)
                ),
              ],
            ),
            child: Obx(() {
              if (controller.userAvatar.value.isEmpty) {
                return ClipOval(
                  child: Image.asset(
                    'assets/images/profilepic.png',
                    fit: BoxFit.cover,
                  ),
                );
              }
              return ClipOval(
                child: Image.network(
                  controller.userAvatar.value,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF09FACA)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profilepic.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          Obx(() => Text(
                controller.userName.value.isEmpty 
                    ? 'User' 
                    : controller.userName.value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )),
          SizedBox(height: 8),
          Obx(() {
            String email = controller.userEmail.value.isEmpty 
                ? 'Email not set' 
                : controller.userEmail.value;
            String phone = controller.userPhone.value.isEmpty 
                ? '' 
                : controller.userPhone.value;
            
            return Text(
              phone.isNotEmpty ? '$email | $phone' : email,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            );
          }),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDarkSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildLightSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconPath;
  final String text;
  final String? badge;
  final Color? badgeColor;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.iconPath,
    required this.text,
    this.badge,
    this.badgeColor,
    this.isDark = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Color(0xFF1A1D29);
    final iconColor = isDark ? Colors.white : Color(0xFF1A1D29);

    return InkWell(
      onTap: onTap,
      splashColor: Color(0xFF09FACA).withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Using network image for icons
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: iconColor,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.circle, size: 20, color: iconColor);
              },
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor?.withOpacity(0.1) ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: badgeColor ?? textColor,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: badgeColor ?? textColor,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: textColor.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}