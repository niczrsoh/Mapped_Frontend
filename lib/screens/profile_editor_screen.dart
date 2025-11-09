import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/profile_editor_controller.dart';

class ProfileEditorScreen extends StatelessWidget {
  ProfileEditorScreen({super.key});
  final controller = Get.put(ProfileEditorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            _buildGradientHeader(controller),
            
            // Form Content
            Padding(
              padding: EdgeInsets.all(16),
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
                    SizedBox(height: 24),
                    
                    // Full Name
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Full name',
                      hint: 'Enter your full name',
                    ),
                    SizedBox(height: 16),
                    
                    // Nickname
                    _buildTextField(
                      controller: controller.nicknameController,
                      label: 'Nick name',
                      hint: 'Enter your nickname',
                    ),
                    SizedBox(height: 16),
                    
                    // Email
                    _buildTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    
                    // Phone Number with Country Flag
                    _buildPhoneField(controller),
                    SizedBox(height: 16),
                    
                    // Country and Gender Row
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
                        SizedBox(width: 12),
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
                    SizedBox(height: 16),
                    
                    // Address
                    _buildTextField(
                      controller: controller.addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      maxLines: 2,
                    ),
                    SizedBox(height: 32),
                    
                    // Cancel Button
                    _buildButton(
                      text: 'CANCEL',
                      onPressed: controller.cancel,
                      isPrimary: false,
                    ),
                    SizedBox(height: 12),
                    
                    // Save Button
                    _buildButton(
                      text: 'SAVE',
                      onPressed: controller.saveProfile,
                      isPrimary: true,
                    ),
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

  Widget _buildGradientHeader(ProfileEditorController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 40),
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
                child: Icon(Icons.person, size: 50, color: Colors.grey),
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
                : 'Lieyza',
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
        SizedBox(height: 8),
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
            fillColor: Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        SizedBox(height: 8),
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
            prefixIcon: Padding(
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
            fillColor: Color(0xFF252836),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Color(0xFF252836),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: getValue(),
            dropdownColor: Color(0xFF252836),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
          backgroundColor: isPrimary ? Color(0xFF09FACA) : Colors.transparent,
          foregroundColor: isPrimary ? Color(0xFF1A1D29) : Color(0xFF09FACA),
          side: BorderSide(
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