import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_controller.dart';

class LanguageScreen extends StatelessWidget {
  LanguageScreen({super.key});
  
  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Language',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your preferred language',
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Language List
            Expanded(
              child: ListView.separated(
                itemCount: controller.languages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = controller.languages[index];
                  return Obx(() {
                    final isSelected = controller.currentLanguage.value == lang['code'];
                    
                    return GestureDetector(
                      onTap: () => controller.changeLanguage(lang['code']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252836),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected 
                              ? Border.all(color: const Color(0xFF09FACA), width: 1.5)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF09FACA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check, 
                                  size: 14, 
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}