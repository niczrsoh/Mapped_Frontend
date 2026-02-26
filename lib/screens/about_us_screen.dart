import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'about_title'.tr(),
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
          crossAxisAlignment: CrossAxisAlignment.center, // Center logos
          children: [
            // 1. MAIN LOGO (TMA4ALL)
            // Replace with your actual asset path
            Image.asset(
              'assets/images/tma4all_logo.png', 
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) => _buildPlaceholderLogo("TMA4ALL Logo"),
            ),
            const SizedBox(height: 24),

            // 2. TEXT CONTENT
            _buildParagraph(
              "about_para_1".tr()
            ),
            _buildParagraph(
              "about_para_2".tr()
            ),
            _buildParagraph(
              "about_para_3".tr()
            ),
            _buildParagraph(
              "about_para_4".tr()
            ),

            const SizedBox(height: 30),

            // 3. PARTNERS SECTION
            Text(
              "about_partners_title".tr(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Partner Logos Grid
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildPartnerLogo('assets/images/ucsi_logo.jpg'),
                _buildPartnerLogo('assets/images/inside_logo.jpg'),
                _buildPartnerLogo('assets/images/phylatto_logo.png'),
                _buildPartnerLogo('assets/images/ikkaido_logo.png'),
                _buildPartnerLogo('assets/images/shin_logo.jpg'),
                _buildPartnerLogo('assets/images/susedgrad_logo.jpg'),
              ],
            ),

            const SizedBox(height: 40),

            // 4. EU FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/eu_flag.png', 
                  height: 40,
                  width: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (c,o,s) => const Icon(Icons.flag, color: Colors.blue, size: 40),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "about_eu_funded_by".tr(),
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF003399), // EU Blue
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "about_eu_name".tr(),
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF003399), // EU Blue
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // Disclaimer
            Text(
              "about_disclaimer_title".tr() + "\n" + "about_disclaimer_body".tr(),
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color.fromARGB(153, 43, 38, 38),
                height: 1.4,
              ),
              textAlign: TextAlign.center, // or TextAlign.left based on preference
            ),
            
            // Bottom padding for scrolling
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper for text paragraphs
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.black, // White text on dark bg
          height: 1.5, // Better readability
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // Helper for partner logos
  Widget _buildPartnerLogo(String assetPath) {
    return Container(
      width: 80, // Adjust size based on your assets
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white, // Logos usually look better on white
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
        },
      ),
    );
  }

  // Temporary placeholder if you don't have the main logo yet
  Widget _buildPlaceholderLogo(String text) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          text, 
          style: const TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 24
          )
        ),
      ),
    );
  }
}