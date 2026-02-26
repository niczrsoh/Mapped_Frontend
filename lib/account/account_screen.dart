// screens/account_screen.dart
import '../../global/routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/account/account_controller.dart';
import 'package:mapped_frontend/account/account_model.dart';
import 'package:mapped_frontend/text_size/text_size_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final AccountController controller = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Gradient Header - Obx wrapper ensures it updates when userData changes
              Obx(() => _buildHeader(controller.headerData)),

              // Main Content with sections
              Transform.translate(
                offset: Offset(0, -48),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Build all sections dynamically
                      ...controller.getAccountSections(context).map((section) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: _buildSection(section),
                        );
                      }).toList(),

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

  Widget _buildHeader(AccountHeaderData headerData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF09FACA).withOpacity(0.6), Color(0xFF09FACA)],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar
          _buildAvatar(
            avatarUrl: headerData.avatarUrl,
            fallbackAsset: 'assets/images/profilepic.png',
          ),

          SizedBox(height: 16),

          // Username
          Text(
            headerData.name,
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
            headerData.email,
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

  Widget _buildAvatar({
    required String avatarUrl,
    required String fallbackAsset,
  }) {
    print('🎨 Building avatar with URL: "$avatarUrl"');

    return Container(
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
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                key: ValueKey(avatarUrl), // Force rebuild when URL changes
                fit: BoxFit.cover,
                // Add cache-busting to force image reload
                headers: {'Cache-Control': 'no-cache'},
                cacheWidth: 96 * 3, // 3x for high DPI screens
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Color(0xFF09FACA),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Error loading avatar: $error');
                  return Image.asset(fallbackAsset, fit: BoxFit.cover);
                },
              )
            : Image.asset(fallbackAsset, fit: BoxFit.cover),
      ),
    );
  }

  /// Build section that groups menu items
  Widget _buildSection(AccountSection section) {
    return Container(
      decoration: BoxDecoration(
        color: section.isDark ? Color(0xFF252836) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: section.items
            .map((item) => _buildMenuItem(item: item, isDark: section.isDark))
            .toList(),
      ),
    );
  }

  Widget _buildMenuItem({required AccountMenuItem item, required bool isDark}) {
    final textColor = isDark ? Colors.white : Color(0xFF1A1D29);
    final iconColor = isDark ? Colors.white : Color(0xFF1A1D29);

    return InkWell(
      onTap: item.onTap,
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
            // Icon
            Image.asset(
              item.iconPath,
              width: 20,
              height: 20,
              color: iconColor,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.circle, size: 20, color: iconColor);
              },
            ),

            SizedBox(width: 12),

            // Text
            Expanded(
              child: Text(
                item.text,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),

            if (item.badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.badgeColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.badgeColor ?? textColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  item.badge!,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: item.badgeColor ?? textColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TextSizeBottomSheet extends StatefulWidget {
  const TextSizeBottomSheet({super.key});

  @override
  State<TextSizeBottomSheet> createState() => _TextSizeBottomSheetState();
}

class _TextSizeBottomSheetState extends State<TextSizeBottomSheet> {
  late double _previewScale;
  late double _originalScale;
  final TextSizeController textSizeController = Get.find<TextSizeController>();

  @override
  void initState() {
    super.initState();
    // Store original value in case user cancels
    _originalScale = textSizeController.textScale.value;
    _previewScale = _originalScale;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            "account_bottomsheet_text_size_title".tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Slider Row
          Row(
            children: [
              const Text(
                "A",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.white,
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12.0,
                      elevation: 4,
                    ),
                  ),
                  child: Slider(
                    value: _previewScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    onChanged: (value) {
                      // Update preview scale and apply to global controller temporarily
                      setState(() {
                        _previewScale = value;
                        // Update globally so preview is visible in real-time
                        textSizeController.textScale.value = value;
                      });
                    },
                  ),
                ),
              ),
              const Text(
                "A",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () async{
                    // Revert to original scale if cancelled
                    textSizeController.textScale.value = _originalScale;
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 100));
                    Get.offAllNamed(AppRoutes.main);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF09FACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'cancel_caps'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09FACA),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // DONE Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Save the preview scale to SharedPreferences
                    await textSizeController.updateTextScale(_previewScale);
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 100));
                    Get.offAllNamed(AppRoutes.main);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'account_bottomsheet_btn_done'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
