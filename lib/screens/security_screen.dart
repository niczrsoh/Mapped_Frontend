import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/controller/security_controller.dart';

class SecurityScreen extends StatelessWidget {
  SecurityScreen({super.key});
  final controller = Get.put(SecurityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1D29), Color(0xFF0D4D4D), Color(0xFF1A1D29)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        'security_title_main'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Common Section
                        _buildSectionHeader('security_header_common'.tr()),
                        const SizedBox(height: 16),

                        _buildSwitchItem(
                          title: 'security_toggle_biometric'.tr(),
                          value: controller.biometricEnabled,
                          onChanged: (val) =>
                              controller.biometricEnabled.value = val,
                        ),

                        const SizedBox(height: 8),

                        _buildActionItem(
                          title: 'security_action_change_password'.tr(),
                          onTap: controller.changePassword,
                        ),

                        const SizedBox(height: 8),

                        _buildActionItem(
                          title: 'security_action_change_passcode'.tr(),
                          onTap: controller.changePasscode,
                        ),

                        const SizedBox(height: 32),

                        // Security Section
                        _buildSectionHeader('security_header_security'.tr()),
                        const SizedBox(height: 12),

                        Text(
                          'security_msg_two_factor_desc'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Two-Factor Authentication
                        Text(
                          'security_toggle_two_factor'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: controller.twoFactorEnabled.value,
                                  onChanged: (val) =>
                                      controller.twoFactorEnabled.value = val,
                                  activeColor: const Color(0xFF09FACA),
                                  activeTrackColor: const Color(
                                    0xFF09FACA,
                                  ).withValues(alpha: 0.5),
                                  inactiveThumbColor: Colors.grey[400],
                                  inactiveTrackColor: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'security_msg_two_factor_info'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Security Help Section
                        _buildSectionHeader('security_header_help'.tr()),
                        const SizedBox(height: 16),

                        _buildActionItem(
                          title: 'security_action_support'.tr(),
                          onTap: controller.openSupport,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value.value,
              onChanged: onChanged,
              activeColor: const Color(0xFF09FACA),
              activeTrackColor: const Color(0xFF09FACA).withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
