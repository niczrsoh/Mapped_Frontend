// screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/help_support/help_support_controller.dart';

class HelpSupportScreen extends StatelessWidget {
  HelpSupportScreen({super.key});

  final HelpSupportController controller = Get.put(HelpSupportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.showSuccessDialog.value) {
          return _buildSuccessView();
        }
        return _buildFormView();
      }),
    );
  }

  // ========== APP BAR ==========
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1D29),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Help and Support',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  // ========== FORM VIEW ==========
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          _buildInfoCard(),
          const SizedBox(height: 24),

          // Form
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                _buildTitleField(),
                const SizedBox(height: 20),

                // Description Field
                _buildDescriptionField(),
                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 24),

                // Contact Info
                _buildContactInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== SUCCESS VIEW ==========
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF09FACA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Checkmark Badge
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF09FACA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 24),

              // Success Message
              Text(
                "We've received your message. Our team will respond soon.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1D29),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.closeSuccessDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'SUBMIT',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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

  // ========== INFO CARD ==========
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252836).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'If you are experiencing any issues, please let us know. We will try to solve them as soon as possible.',
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ========== TITLE FIELD ==========
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.titleController,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Add your grievance title here',
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ========== DESCRIPTION FIELD ==========
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explain the problem',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 8,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Type your enquiry here',
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please describe your problem';
            }
            if (value.trim().length < 10) {
              return 'Please provide more details (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ========== SUBMIT BUTTON ==========
  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF09FACA),
              foregroundColor: const Color(0xFF1A1D29),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A1D29),
                    ),
                  )
                : Text(
                    'SUBMIT',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ));
  }

  // ========== CONTACT INFO ==========
  Widget _buildContactInfo() {
    return Column(
      children: [
        Text(
          'Need more help? Contact our support team or browse our FAQs for answers to common questions at ',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        GestureDetector(
          onTap: controller.contactSupport,
          child: Text(
            'info@insideeu.eu',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF09FACA),
              height: 1.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}