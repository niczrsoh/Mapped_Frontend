import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/coachBot/coachBot_controller.dart';
import 'package:mapped_frontend/coachBot/coachBot_history_screen.dart';

class CoachBotScreen extends StatelessWidget {
  CoachBotScreen({super.key});
  final controller = Get.put(CoachBotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CoachBot',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                        Get.to(() => CoachBotHistoryScreen());
                    },
                     tooltip: 'Chat History',
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Greeting
                      Obx(
                        () => RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hello, ',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF09FACA),
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: controller.userName.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'How can I help\nyou today?',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Quick Action Buttons
                      _buildQuickActionButton(
                        icon: Icons.school_outlined, // Good for history/learning
                        title: 'What is a safe way to teach blocks to a participant with poor vision?',
                        onTap: () => controller.explainHistory(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.center_focus_strong, // Perfect for techniques
                        title: 'What are good ways to support a participant who struggles to focus?',
                        onTap: () => controller.showTechniques(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.sports_martial_arts, // Good for location
                        title: 'Give me ideas for warm-up games that include everyone.',
                        onTap: () => controller.findDojang(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.explore,
                        title: 'How can I help a student who is very shy and afraid to spar?',
                        onTap: () => controller.showOtherOptions(),
                      ),

                      const SizedBox(height: 60),

                      // Privacy Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252836).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your conversations are processed to improve the technologies powering CoachBot. Don\'t enter anything that you wouldn\'t want to be reviewed or used.',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Disclaimer
                      Center(
                        child: Text(
                          'CoachBot may display inaccurate info, including about people, so double-check its responses.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.white38,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D29),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252836),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        style: GoogleFonts.roboto(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter a prompt here...',
                          hintStyle: GoogleFonts.roboto(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white54),
                            onPressed: controller.startVoiceInput,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (value) => controller.sendMessage(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF09FACA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => controller.sendMessage(
                        controller.messageController.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF252836),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF09FACA).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF09FACA), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
