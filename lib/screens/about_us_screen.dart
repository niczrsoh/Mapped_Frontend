import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          'About Us',
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
              "MAPPED is part of the Traditional Martial Arts for All (TMA4ALL) project - a groundbreaking European initiative dedicated to making all traditional martial arts accessible and inclusive for everyone (Project 101133802 — TMA4ALL)."
            ),
            _buildParagraph(
              "We believe that all traditional martial arts can transform lives through physical, psychological and social development, regardless of the style. In fact, research consistently shows that the martial arts coach is the most important factor in improving health, well-being and quality of life among practitioners, regardless of the martial art itself. Our mission is to support all traditional martial arts coaches in creating safe, empowering sessions that welcome people of all abilities, backgrounds, ages and disabilities."
            ),
            _buildParagraph(
              "Developed through collaboration between leading inclusive martial arts organisations and universities across Europe, MAPPED is the first fully accessible and inclusive app designed specifically for grassroots martial arts coaches. Whether you're an aspiring coach or an experienced instructor, MAPPED provides the tools, support and community you need to deliver high-quality inclusive martial arts sessions."
            ),
            _buildParagraph(
              "Join our growing international network of coaches who are using traditional martial arts to improve lives and build stronger, more inclusive communities."
            ),

            const SizedBox(height: 30),

            // 3. PARTNERS SECTION
            Text(
              "Our Partners",
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
                      "Co-funded by",
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF003399), // EU Blue
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "the European Union",
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
              "Disclaimer\nFunded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Education and Culture Executive Agency (EACEA). Neither the European Union nor EACEA can be held responsible for them.",
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