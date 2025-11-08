import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../global/routes.dart';

class TouchIdScreen extends StatelessWidget {
  const TouchIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F161C), Color(0xFF0B1116)],
          ),
        ),
        child: Stack(
          children: [
            // radial glow layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.25),
                    radius: 0.8,
                    colors: [
                      Color(0xFF0FB3A0).withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'Touch ID',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      'Place and hold your finger on the Finger reader',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // fingerprint outer circle with subtle highlights for 3D look
                  // fingerprint outer circle with subtle highlights for 3D look
                  // slightly reduce the circle size to match requested smaller radius
                  Container(
                    width: size.width * 0.26,
                    height: size.width * 0.26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.75,
                        colors: const [Color(0xFF2F5856), Color(0xFF132F2D)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0FB3A0).withOpacity(0.16),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 2.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // top-left highlight (soft bevel)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.35),
                                radius: 0.9,
                                colors: [
                                  Colors.white.withOpacity(0.06),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // bottom-right shadow (adds depth)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(0.45, 0.45),
                                radius: 0.9,
                                colors: [
                                  Colors.black.withOpacity(0.14),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.9],
                              ),
                            ),
                          ),
                        ),

                        // subtle inner noise/texture (very faint)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                          ),
                        ),

                        // fingerprint icon on top (use bright teal from design)
                        // fingerprint icon on top (scaled with circle)
                        Icon(
                          Icons.fingerprint,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          size: size.width * 0.085,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'One Moment...',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Login with Email button
                  Center(
                    child: SizedBox(
                      width: size.width * 0.7,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Get.toNamed(AppRoutes.login);
                        },
                        child: Text(
                          'Login with Email',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),
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
}
