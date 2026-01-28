// screens/account_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/account_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/screens/notification_screen.dart';
import 'package:mapped_frontend/screens/profile_editor_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});
  
  final AccountController controller = Get.find<AccountController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: Obx(() {
        // Show loading indicator while fetching user data
        if (userController.isLoading.value && userController.userData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFF09FACA),
            ),
          );
        }
        
        return SingleChildScrollView(
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileEditorScreen(
                                  userData: userController.userData.value,
                                ),
                              ),
                            );
                          },
                        ),
                        Obx(
                          () => _MenuItem(
                            iconPath: 'assets/images/notification.png',
                            text: 'Notifications',
                            badge: controller.notificationsEnabled.value ? 'ON' : 'OFF',
                            badgeColor: Color(0xFF09FACA),
                            onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                          ),
                        ),
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
                          ),
                        ),
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
                      
                      // Refresh button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: userController.fetchUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF09FACA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            'Refresh Profile Data',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGradientHeader() {
    return Obx(() {
      final user = userController.userData.value;
      final name = userController.userName;
      final email = user['email'] ?? 'No email';
      final avatar = user['avatar'] ?? '';
      
      // Format created date
      String createdAt = '';
      if (user['createdAt'] != null) {
        try {
          final date = DateTime.parse(user['createdAt']).toLocal();
          createdAt = 'Member since ${date.day}/${date.month}/${date.year}';
        } catch (e) {
          createdAt = '';
        }
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 50, bottom: 80),
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatar.isNotEmpty
                    ? Image.network(
                        'https://mapped-backend-node-js.onrender.com/$avatar', // Update with your base URL
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/profilepic.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/profilepic.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Username
            Text(
              userController.userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                height: 20 / 14,
                letterSpacing: 0.25,
                color: Colors.white,
              ),    
            ),
            
            SizedBox(height: 8),
            
            // Email
            Text(
              email,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.25,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 4),
            
            // Member since
            if (createdAt.isNotEmpty)
              Text(
                createdAt,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      );
    });
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
                  color: badgeColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: badgeColor ?? textColor,
                    width: 1,
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
          ],
        ),
      ),
    );
  }
}