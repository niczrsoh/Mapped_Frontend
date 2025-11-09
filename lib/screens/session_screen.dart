import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C23),
        title: Text(
          'Sessions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Session Screen Content',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
        ),
      ),
    );
  }
}
