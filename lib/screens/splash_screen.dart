import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../global/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late AnimationController _circleController;
  late AnimationController _textController;

  int _currentStage = 0;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Stage 0: Glowing map pin logo (Splash 1)
    setState(() => _currentStage = 0);
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 2000));
    await _fadeController.reverse();

    // Stage 1: Martial artist silhouette (Splash 2)
    setState(() => _currentStage = 1);
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 2000));
    await _fadeController.reverse();

    // Stage 2: "Explore with MAPPED" circle (Splash 3)
    setState(() => _currentStage = 2);
    _fadeController.forward();
    _circleController.forward();
    await Future.delayed(Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(Duration(milliseconds: 2000));
    await _fadeController.reverse();
    _circleController.reset();
    _textController.reset();

    // Stage 3: Welcome text fade in (Splash 4)
    setState(() => _currentStage = 3);
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 1500));
    await _fadeController.reverse();

    // Navigate to Splash 5 (Start/Login page)
    if (mounted) {
      Get.offNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a4d3c), Color(0xFF1a1f2e), Color(0xFF0f1419)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: _buildCurrentStage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStage() {
    switch (_currentStage) {
      case 0:
        return _buildGlowingMapPin();
      case 1:
        return _buildMartialArtistSilhouette();
      case 2:
        return _buildExploreWithMapped();
      default:
        return Container();
    }
  }

  // Splash 1: Glowing background with your image
  Widget _buildGlowingMapPin() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Animated glow effect
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(
                      0xFF00D9B5,
                    ).withValues(alpha: 0.5 + _glowController.value * 0.3),
                    Color(
                      0xFF00D9B5,
                    ).withValues(alpha: 0.2 + _glowController.value * 0.2),
                    Color(0xFF00D9B5).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            // Your image
            Image.asset(
              'assets/images/splash1.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.location_on,
                  size: 100,
                  color: Color(0xFF00D9B5),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Splash 2: Your image with fade effect
  Widget _buildMartialArtistSilhouette() {
    return Image.asset(
      'assets/images/splash2.png',
      width: 300,
      height: 300,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.sports_martial_arts,
          size: 150,
          color: Color(0xFF2d4a5c).withValues(alpha: 0.6),
        );
      },
    );
  }

  // Splash 3: "Explore with MAPPED" with animated circle
  Widget _buildExploreWithMapped() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _circleController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(240, 240),
              painter: AnimatedCirclePainter(
                progress: _circleController.value,
                color: Color(0xFF00D9B5),
              ),
            );
          },
        ),
        FadeTransition(
          opacity: _textController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore with',
                style: GoogleFonts.deliusSwashCaps(
                  fontSize: 20,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'MAPPED',
                style: GoogleFonts.deliusSwashCaps(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Map Pin Painter
class MapPinPainter extends CustomPainter {
  final double glowIntensity;

  MapPinPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00D9B5).withValues(alpha: glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Color(0xFF00D9B5).withValues(alpha: glowIntensity * 0.2)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final pinWidth = size.width * 0.65;
    final pinHeight = size.height * 0.85;

    final path = Path();
    path.moveTo(centerX, pinHeight);
    path.quadraticBezierTo(
      centerX - pinWidth / 3,
      pinHeight - pinHeight / 4,
      centerX - pinWidth / 2,
      pinHeight / 2,
    );
    path.arcToPoint(
      Offset(centerX + pinWidth / 2, pinHeight / 2),
      radius: Radius.circular(pinWidth / 2),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + pinWidth / 3,
      pinHeight - pinHeight / 4,
      centerX,
      pinHeight,
    );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Martial artist icon inside
    final iconPaint = Paint()
      ..color = Color(0xFF00D9B5).withValues(alpha: glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final figY = size.height * 0.3;
    canvas.drawCircle(Offset(centerX, figY - 5), 8, iconPaint);

    final figPath = Path();
    figPath.moveTo(centerX, figY + 5);
    figPath.lineTo(centerX - 18, figY + 30);
    figPath.moveTo(centerX, figY + 12);
    figPath.lineTo(centerX + 28, figY + 18);
    figPath.moveTo(centerX, figY + 30);
    figPath.lineTo(centerX - 12, figY + 50);
    figPath.moveTo(centerX, figY + 30);
    figPath.lineTo(centerX + 35, figY + 28);

    canvas.drawPath(figPath, iconPaint);
  }

  @override
  bool shouldRepaint(MapPinPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

// Kick Silhouette Painter
class KickSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2d4a5c).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Head
    canvas.drawCircle(Offset(cx - 30, cy - 70), 28, paint);

    // Body and limbs
    final bodyPath = Path();
    bodyPath.moveTo(cx - 30, cy - 42);
    bodyPath.lineTo(cx - 60, cy);
    bodyPath.lineTo(cx - 40, cy + 10);
    bodyPath.lineTo(cx - 10, cy - 10);
    bodyPath.close();

    bodyPath.moveTo(cx - 10, cy - 10);
    bodyPath.lineTo(cx + 80, cy - 20);
    bodyPath.lineTo(cx + 90, cy - 10);
    bodyPath.lineTo(cx + 10, cy);
    bodyPath.close();

    bodyPath.moveTo(cx - 40, cy + 10);
    bodyPath.lineTo(cx - 50, cy + 75);
    bodyPath.lineTo(cx - 35, cy + 80);
    bodyPath.lineTo(cx - 25, cy + 15);
    bodyPath.close();

    bodyPath.moveTo(cx - 15, cy + 10);
    bodyPath.lineTo(cx + 40, cy + 75);
    bodyPath.lineTo(cx + 52, cy + 70);
    bodyPath.lineTo(cx, cy + 5);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Circle Painter
class AnimatedCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  AnimatedCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(AnimatedCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// SPLASH 5: Welcome Screen with Image Background
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image - Full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome.jpg', // Your image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image not found
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0a4d3c),
                        Color(0xFF1a1f2e),
                        Color(0xFF0f1419),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Optional: Dark overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Push content to bottom
                children: [
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A5848), // #0A5848 at 0%
                        Color(0xFF09FACA), // #09FACA at 100%
                      ],
                      stops: [0.0, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'MAPPED',
                      style: const TextStyle(
                        fontFamily: 'NicoMoji',
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Martial Art Coaches',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF00FAFE),
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 60),

                  // Buttons Row
                  Row(
                    children: [
                      // Start Button
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/onboarding');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00D9B5),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Color(
                                0xFF00D9B5,
                              ).withValues(alpha: 0.5),
                            ),
                            child: Text(
                              'Start',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 15),

                      // Login Button
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.toNamed('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF00D9B5),
                                width: 2,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 60), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SPLASH 6-8: Onboarding Screens (Register button on last page)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Explore with Us',
      subtitle: 'Your Martial Arts Journey Starts Here',
      imagePath: 'assets/images/onboarding1.png',
    ),
    OnboardingData(
      title: 'Explore with Us',
      subtitle: 'Level Up Your Martial Skills',
      imagePath: 'assets/images/onboarding2.png',
    ),
    OnboardingData(
      title: 'Register Now',
      subtitle: 'Start your coaching journey',
      imagePath: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a4d3c), Color(0xFF1a1f2e), Color(0xFF0f1419)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildIndicators(),
                    SizedBox(height: 20),
                    if (_currentPage < _pages.length - 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _pages.length - 1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF00D9B5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    if (_currentPage == _pages.length - 1)
                      _buildRegisterButton()
                    else
                      _buildNextButton(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ellipse with gradient border - UPDATED
          SizedBox(
            width: 328,
            height: 328,
            child: CustomPaint(
              size: Size(328, 328),
              painter: GradientBorderCirclePainter(),
              child: Padding(
                padding: EdgeInsets.all(24), // Space between border and content
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent, // Background color from Figma
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      data.imagePath,
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image doesn't exist
                        return Icon(
                          Icons.sports_martial_arts,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.5),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Color(0xFF00D9B5)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed(AppRoutes.register);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9B5),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00D9B5),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class GradientBorderCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw gradient border
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Calculate gradient angle (136.44 degrees to radians)
    // 136.44° = 2.38 radians
    // Convert to Alignment coordinates
    final double angle = 136.44 * math.pi / 180;
    final dx = math.cos(angle);
    final dy = math.sin(angle);

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-dx, -dy),
        end: Alignment(dx, dy),
        colors: [
          Color(0xFF00FFA6), // Green at 14.85%
          Color(
            0xFFA77CBE,
          ).withValues(alpha: 0), // Transparent purple at 34.62%
          Color(0xFF6FA8C3).withValues(alpha: 0), // Transparent blue at 57.43%
          Color(0xFF09FACA), // Cyan at 85.31%
        ],
        stops: [0.1485, 0.3462, 0.5743, 0.8531],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 0.5, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
