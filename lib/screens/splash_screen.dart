import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Route names – adjust if you have a global routes file
class AppRoutes {
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String login = '/login';
}

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Stage 0: Glowing map pin logo
    setState(() => _currentStage = 0);
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _fadeController.reverse();

    // Stage 1: Martial artist silhouette
    setState(() => _currentStage = 1);
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _fadeController.reverse();

    // Stage 2: "Explore with MAPPED" animated circle
    setState(() => _currentStage = 2);
    _fadeController.forward();
    _circleController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _fadeController.reverse();
    _circleController.reset();
    _textController.reset();

    // Stage 3: Welcome text fade in
    setState(() => _currentStage = 3);
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    await _fadeController.reverse();

    // Navigate to the WelcomeScreen
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
            colors: const [Color(0xFF0a4d3c), Color(0xFF1a1f2e), Color(0xFF0f1419)],
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

  // Splash 1: Glowing map pin
  Widget _buildGlowingMapPin() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Animated glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D9B5).withValues(alpha: 0.5 + _glowController.value * 0.3),
                    const Color(0xFF00D9B5).withValues(alpha: 0.2 + _glowController.value * 0.2),
                    const Color(0xFF00D9B5).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            // Image asset
            Image.asset(
              'assets/images/splash1.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.location_on,
                  size: 100,
                  color: const Color(0xFF00D9B5),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Splash 2: Martial artist silhouette
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
          color: const Color(0xFF2d4a5c).withValues(alpha: 0.6),
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
              size: const Size(240, 240),
              painter: AnimatedCirclePainter(
                progress: _circleController.value,
                color: const Color(0xFF00D9B5),
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
              const SizedBox(height: 8),
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

// ------------------------------------------------------------
// Custom painters used in the splash screen
// ------------------------------------------------------------

class MapPinPainter extends CustomPainter {
  final double glowIntensity;

  MapPinPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9B5).withValues(alpha: glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF00D9B5).withValues(alpha: glowIntensity * 0.2)
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

    // Simple martial artist figure inside the pin
    final iconPaint = Paint()
      ..color = const Color(0xFF00D9B5).withValues(alpha: glowIntensity)
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

class KickSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2d4a5c).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Head
    canvas.drawCircle(Offset(cx - 30, cy - 70), 28, paint);

    // Body and limbs (simplified)
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

// ------------------------------------------------------------
// Welcome Screen (Splash 5)
// ------------------------------------------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full‑screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
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

          // Semi‑transparent overlay for better text contrast
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
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [
                        Color(0xFF0A5848),
                        Color(0xFF09FACA),
                      ],
                      stops: const [0.0, 1.0],
                    ).createShader(bounds),
                    child: const Text(
                      'MAPPED',
                      style: TextStyle(
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
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Martial Art Coaches',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF00FAFE),
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.onboarding);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9B5),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF00D9B5).withValues(alpha: 0.5),
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.login);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
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

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Onboarding Screens (Splash 6‑8) – FIXED VERSION
// ------------------------------------------------------------
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
      title: 'Martial Arts For All',
      subtitle: 'Learn How To Make Martial Arts Inclusive For Everyone',
      imagePath: 'assets/images/onboarding1.png',
    ),
    OnboardingData(
      title: 'Explore with Us', // not used for index 1 (image removed)
      subtitle: 'Level Up Your Martial Skills',
      imagePath: 'assets/images/onboarding2.png',
    ),
    OnboardingData(
      title: '', // Empty title for screen three (no title displayed)
      subtitle: 'Funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Education and Culture Executive Agency (EACEA). Neither the European Union nor EACEA can be held responsible for them.',
      imagePath: 'assets/images/onboarding3.png',
    ),
  ];

  // The long description for the second screen (exactly as provided in the image)
  final String secondScreenDescription =
      'MAPPED is part of the Traditional Martial Arts for All (TMA4ALL) project - a groundbreaking European initiative dedicated to making all traditional martial arts accessible and inclusive for everyone (Project 101133802 — TMA4ALL).\n\n'
      'We believe that all traditional martial arts can transform lives through physical, psychological and social development, regardless of the style. In fact, research consistently shows that the martial arts coach is the most important factor in improving health, well-being and quality of life among practitioners, regardless of the martial art itself. Our mission is to support all traditional martial arts coaches in creating safe, empowering sessions that welcome people of all abilities, backgrounds, ages and disabilities.\n\n'
      'Developed through collaboration between leading inclusive martial arts organisations and universities across Europe, MAPPED is the first fully accessible and inclusive app designed specifically for grassroots martial arts coaches. Whether you\'re an aspiring coach or an experienced instructor, MAPPED provides the tools, support and community you need to deliver high-quality inclusive martial arts sessions.\n\n'
      'Join our growing international network of coaches who are using traditional martial arts to improve lives and build stronger, more inclusive communities.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [Color(0xFF0a4d3c), Color(0xFF1a1f2e), Color(0xFF0f1419)],
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
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    // Second screen: no image, scrollable text centered vertically and horizontally
    if (index == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Text(
                      secondScreenDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center, // Centered horizontally
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Default layout for screens 0 and 2: image with gradient border + title/subtitle
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with gradient border – FIXED: border now appears as a ring
              SizedBox(
                width: 328,
                height: 328,
                child: Stack(
                  clipBehavior: Clip.none, // Allow border to extend beyond image
                  children: [
                    ClipOval(
                      child: Image.asset(
                        data.imagePath,
                        width: 328,
                        height: 328,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.sports_martial_arts,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.5),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              // Conditionally show title if it's not empty
              if (data.title.isNotEmpty) ...[
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Scrollable subtitle (especially important for the long EU text on screen 2)
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Unified bottom section: indicators + Skip (except last page) + main button
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildIndicators(),
          const SizedBox(height: 20),
          // Skip button (only if not on the last page)
          if (_currentPage < _pages.length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _pageController.animateToPage(
                    _pages.length - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF00D9B5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          // Main action button: Continue or Register
          if (_currentPage == _pages.length - 1)
            _buildRegisterButton()
          else
            _buildNextButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF00D9B5)
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9B5),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
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
    final double strokeWidth = 2.0;
    final double radius = size.width / 2; // Inner edge = radius - 1

    // Gradient angle: 136.44° in radians
    const double angle = 136.44 * math.pi / 180;
    final dx = math.cos(angle);
    final dy = math.sin(angle);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: const [
        Color(0xFF00FFA6),
        Color(0xFFA77CBE),
        Color(0xFF6FA8C3),
        Color(0xFF09FACA),
      ],
      stops: const [0.1485, 0.3462, 0.5743, 0.8531],
    ).createShader(rect);

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}