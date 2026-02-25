import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_editor_controller.dart';

class ProfileEditorScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? userData;

  const ProfileEditorScreen({super.key, this.userData});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  late ProfileEditorController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ProfileEditorController(),
      tag: 'profile_editor_${widget.userData?['_id'] ?? 'default'}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithUserData(widget.userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When user presses back button, just go back without refreshing
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1D29),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'profile_edit_title'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [_buildGradientHeader(), _buildFormContent()],
          ),
        ),
      ),
    );
  }

  // ========== GRADIENT HEADER ==========
  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF09FACA).withOpacity(0.6),
            const Color(0xFF09FACA),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildProfileAvatar(),
          const SizedBox(height: 16),
          _buildUserInfo(),
        ],
      ),
    );
  }

  // ========== PROFILE AVATAR ==========
  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        Obx(
          () => Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D29),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ========== PROFILE IMAGE ==========
  Widget _buildProfileImage() {
    final imageUrl = controller.profileImage.value;

    if (imageUrl.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.grey);
    }

    // Check if it's a local file (newly selected image)
    if (!imageUrl.startsWith('http') && !kIsWeb) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 50, color: Colors.grey);
        },
      );
    }

    // Network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 50, color: Colors.grey);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: const Color(0xFF09FACA),
          ),
        );
      },
    );
  }

  // ========== USER INFO ==========
  Widget _buildUserInfo() {
    return Obx(() {
      final profile = controller.userProfile.value;
      return Column(
        children: [
          Text(
            profile?.displayName ?? 'profile_edit_user_fallback'.tr(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: const Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${profile?.displayEmail ?? ''} | ${profile?.displayPhone ?? ''}',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              color: const Color(0xFF1A1D29),
            ),
          ),
        ],
      );
    });
  }

  // ========== FORM CONTENT ==========
  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: controller.nameController,
              label: 'profile_edit_lbl_name'.tr(),
              hint: 'profile_edit_hint_name'.tr(),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: controller.usernameController,
              label: 'profile_edit_lbl_username'.tr(),
              hint: 'profile_edit_hint_username'.tr(),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: controller.emailController,
              label: 'profile_edit_lbl_email'.tr(),
              hint: 'profile_edit_hint_email'.tr(),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            _buildPhoneField(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildCountryDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderDropdown()),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: controller.addressController,
              label: 'profile_edit_lbl_address'.tr(),
              hint: 'profile_edit_hint_address'.tr(),
              maxLines: 2,
              maxLength: 100,
            ),
            const SizedBox(height: 32),

            _buildCancelButton(),
            const SizedBox(height: 12),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ========== TEXT FIELD ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(fontSize: 14, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterStyle: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'profile_edit_validator_required'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  // ========== PHONE FIELD ==========
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_edit_lbl_phone'.tr(),
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 20,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🇲🇾', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                ],
              ),
            ),
            hintText: 'profile_edit_hint_phone'.tr(),
            hintStyle: GoogleFonts.roboto(fontSize: 14, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterStyle: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'profile_edit_validator_phone'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  // ========== COUNTRY DROPDOWN ==========
  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_edit_lbl_country'.tr(),
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF252836),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: controller.selectedCountry.value,
              dropdownColor: const Color(0xFF252836),
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 0.25,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: controller.countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCountry.value = value;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ========== GENDER DROPDOWN ==========
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_edit_lbl_gender'.tr(),
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF252836),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: controller.selectedGender.value,
              dropdownColor: const Color(0xFF252836),
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 0.25,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: controller.genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedGender.value = value;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ========== BUTTONS ==========
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Just go back without any changes
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF09FACA),
          side: const BorderSide(color: Color(0xFF09FACA), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'cancel_caps'.tr(),
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isSaving.value ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF09FACA),
            foregroundColor: const Color(0xFF1A1D29),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1D29),
                  ),
                )
              : Text(
                  'save_caps'.tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  // ========== DIALOGS ==========
  void _showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'profile_edit_dialog_img_title'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                label: 'gallery'.tr(),
                onTap: () {
                  Get.back();
                  controller.pickImageFromGallery();
                },
              ),
              const SizedBox(height: 12),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                label: 'camera'.tr(),
                onTap: () {
                  Get.back();
                  controller.pickImageFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D29),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF09FACA), size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HANDLERS ==========
  Future<void> _handleSave() async {
    final success = await controller.saveProfile();

    if (success) {
      Navigator.of(context).pop();
    }
  }
}
