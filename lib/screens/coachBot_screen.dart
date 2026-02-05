import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'coachBot_chat_screen.dart';

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
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
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
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
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
                        title: 'Explain Taekwondo History & Philosophy',
                        onTap: () => controller.explainHistory(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.sports_martial_arts, // Perfect for techniques
                        title: 'Show me Taekwondo Techniques',
                        onTap: () => controller.showTechniques(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.location_on_outlined, // Good for location
                        title: 'Find a Training Hall Nearby',
                        onTap: () => controller.findDojang(),
                      ),

                      const SizedBox(height: 12),

                      _buildQuickActionButton(
                        icon: Icons.explore,
                        title: 'Show me other options',
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

class CoachBotController extends GetxController {
  var userName = 'Lieyza'.obs;
  final messageController = TextEditingController();

  void _navigateToChatWithDraft(String draftText) {
    // We pass the text as an argument, but we DO NOT send it yet.
    Get.to(() => CoachBotChatScreen(), arguments: draftText);
  }

  // Quick Actions now just draft the message
  void explainHistory() {
    _navigateToChatWithDraft('Explain Taekwondo History & Philosophy');
  }

  void showTechniques() {
    _navigateToChatWithDraft('Show me Taekwondo Techniques');
  }

  void findDojang() {
    _navigateToChatWithDraft('Find a Training Hall Nearby');
  }

  void showOtherOptions() {
    _navigateToChatWithDraft('Show me other options');
  }

  void sendMessage(String message) {
    final text = message.trim();
    if (text.isEmpty) return;
    
    messageController.clear();
    // Pass the typed text to the chat screen to continue editing
    _navigateToChatWithDraft(text);
  }

  void startVoiceInput() {
    Get.snackbar(
      'Voice Input',
      'Listening...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
  //messageController.dispose();
    super.onClose();
  }
}
