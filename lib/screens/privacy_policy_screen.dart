import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy and Policy',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy and Policy",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildParagraph(
              "MAPPED is committed to protecting your privacy and ensuring your data is handled responsibly.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("What We Collect"),
            _buildParagraph(
              "We collect basic account information such as your name and email, coaching profile details, progress within the belt system, session planning inputs, and activity within the coach community. We may also collect limited technical data to improve app performance.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("How We Use Your Data"),
            _buildParagraph(
              "Your information is used to personalise your development pathway, track your progress, provide tailored strategies and learning resources, and enhance your overall experience within the app. We do not sell or share your personal data with third parties.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Data Protection"),
            _buildParagraph(
              "We apply appropriate security measures to safeguard your information. Access to data is restricted to authorised personnel only.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Your Responsibility"),
            _buildParagraph(
              "Coaches must ensure that any participant information entered into the app is anonymised and that appropriate consent has been obtained where required.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Your Rights"),
            _buildParagraph(
              "You may request access, correction, or deletion of your data at any time by contacting our support team.",
            ),
            const SizedBox(height: 24),
            Text(
              "By using MAPPED, you agree to this Privacy and Policy statement.",
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.roboto(fontSize: 14, color: Colors.black, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }
}
