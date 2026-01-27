import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/profile_editor_controller.dart';

class ProfileEditorScreen extends StatelessWidget {
  final Map<dynamic, dynamic>? userData;
  
  ProfileEditorScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with user data
    final controller = Get.put(
      ProfileEditorController(userData: userData),
      tag: 'profile_editor_${userData?['_id'] ?? 'default'}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      // Stack allows us to put the Loading Indicator ON TOP of the form
      body: Obx(() => Stack(
        children: [
          // 1. The Main Form Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildGradientHeader(controller),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Editor',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          controller: controller.nameController,
                          label: 'Full name',
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: controller.nicknameController,
                          label: 'Nick name',
                          hint: 'Enter your nickname',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: controller.emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildPhoneField(controller),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Country',
                                controller: controller,
                                getValue: () => controller.selectedCountry.value,
                                items: controller.countries,
                                onChanged: (value) => controller.selectedCountry.value = value!,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Gender',
                                controller: controller,
                                getValue: () => controller.selectedGender.value,
                                items: controller.genders,
                                onChanged: (value) => controller.selectedGender.value = value!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: controller.addressController,
                          label: 'Address',
                          hint: 'Enter your address',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 32),
                        
                        _buildButton(
                          text: 'CANCEL',
                          onPressed: controller.cancel,
                          isPrimary: false,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildButton(
                          text: 'SAVE',
                          onPressed: controller.saveProfile,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. The Loading Overlay (Shows when isLoading is true)
          if (controller.isLoading.value)
            Container(
              color: Colors.black54, // Semi-transparent black
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF09FACA),
                ),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildGradientHeader(ProfileEditorController controller) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 50, bottom: 40),
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
            // Profile Avatar with Edit Button
            Stack(
              children: [
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
                  child: controller.profileImage.value.isNotEmpty 
                      ? controller.profileImage.value.startsWith('http')
                        ? ClipOval(
                            child: Image.network(
                              controller.profileImage.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, size: 50, color: Colors.grey);
                              },
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              controller.profileImage.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, size: 50, color: Colors.grey);
                              },
                            ),
                          )
                      : Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.changeProfilePicture,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1D29),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Username
            Obx(() => Text(
              controller.displayName.value.isNotEmpty 
                  ? controller.displayName.value 
                  : 'User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                height: 28 / 22,
                color: Color(0xFF1A1D29),
              ),
            )),
            SizedBox(height: 8),
            
            // Email & Phone
            Obx(() => Text(
              '${controller.displayEmail.value} | ${controller.displayPhone.value}',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.25,
                color: Color(0xFF1A1D29),
              ),
            )),
          ],
        ),
      );
    });
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white38,
            ),
            filled: true,
            fillColor: const Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(ProfileEditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
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
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇲🇾',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            hintText: 'Enter phone number',
            hintStyle: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white38,
            ),
            filled: true,
            fillColor: const Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required ProfileEditorController controller,
    required String Function() getValue,
    required List<String> items,
    required Function(String?) onChanged,
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
        Obx(() => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: getValue(),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        )),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF09FACA) : Colors.transparent,
          foregroundColor: isPrimary ? const Color(0xFF1A1D29) : const Color(0xFF09FACA),
          side: const BorderSide(
            color: Color(0xFF09FACA),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}