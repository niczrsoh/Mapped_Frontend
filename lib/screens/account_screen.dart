import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/controller/controller/account_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});
  final AccountController controller = Get.put(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            _buildGradientHeader(),
            
            // Main Content
            Transform.translate(
              offset: Offset(0, -48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // First Section - Dark
                    _buildDarkSection([
                      _MenuItem(
                        iconPath: 'assets/images/profile.png',
                        text: 'Edit profile information',
                        onTap: controller.editProfile,
                      ),
                      Obx(
                        () => _MenuItem(
                        iconPath: 'assets/images/notification.png',
                        text: 'Notifications',
                        badge: controller.notificationsEnabled.value ? 'ON' : 'OFF',
                        badgeColor: Color(0xFF09FACA),
                        onTap: controller.navigateToNotifications,
                      )),
                      _MenuItem(
                        iconPath: 'assets/images/logout.png',
                        text: 'Log Out',
                        onTap: controller.logout,
                      ),
                    ]),
                    
                    SizedBox(height: 16),
                    
                    // Second Section - Light
                    _buildLightSection([
                      Obx(
                        () => _MenuItem(
                        iconPath: 'assets/images/security.png',
                        text: 'Security',
                        badge: controller.securityMethod.value,
                        badgeColor: Color(0xFF09FACA),
                        isDark: false,
                        onTap: controller.navigateToSecurity,
                      )),
                      _MenuItem(
                        iconPath: 'assets/images/language.png',
                        text: 'Language',
                        isDark: false,
                        onTap: controller.navigateToLanguage,
                      ),
                    ]),
                    
                    SizedBox(height: 16),
                    
                    // Third Section - Dark
                    _buildDarkSection([
                      _MenuItem(
                        iconPath: 'assets/images/help.png',
                        text: 'Help & Support',
                        onTap: controller.navigateToHelp,
                      ),
                      _MenuItem(
                        iconPath: 'assets/images/privacy.png',
                        text: 'Privacy policy',
                        onTap: controller.navigateToPrivacy,
                      ),
                      _MenuItem(
                        iconPath: 'assets/images/about.png',
                        text: 'About Us',
                        onTap: controller.navigateToAbout,
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
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF09FACA).withValues(alpha: 0.6),
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
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profilepic.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Username
          Text(
            'Lieyza',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              height: 20 / 14,
              letterSpacing: 0.25,
              color: Colors.white,
            ),    
          ),
          
          SizedBox(height: 8),
          
          // Email & Phone
          Text(
            'youremail@domain.com | +01 234 567 89',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.25,
              color: Colors.white,
            ),
          ),
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
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildLightSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items,
      ),
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

    return InkWell(
      onTap: onTap,
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
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: textColor,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0.25,
                  color: textColor,
                ),
              ),
            ),
            if (badge != null)
              Text(
                badge!,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: badgeColor ?? textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}