import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:shared_preferences/shared_preferences.dart';          // <-- added
import 'package:mapped_frontend/global/routes.dart';                   // <-- added (must contain AppRoutes.main & AppRoutes.adminReport)

// ------------------------------------------------------------
// Route names (if not already defined elsewhere, you can keep them here)
// ------------------------------------------------------------
class AppRoutes {
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String login = '/login';
  // These two must exist in your actual routes file
  static const String main = '/main';
  static const String adminReport = '/admin-report';
}

// ------------------------------------------------------------
// Splash Screen
// ------------------------------------------------------------
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

  // --- New variables for auto‑login ---
  String? _nextRoute;          // will hold the destination after animation
  bool _sessionChecked = false; // becomes true when the login check finishes

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

    // --- Start both the animation and the session check ---
    _checkLoginStatus();        // <-- added
    _startSplashSequence();
  }

  // --- New method: check if user is already logged in ---
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      // User has a saved session – restore the user ID and fetch profile
      final userController = Get.find<UserController>();
      userController.userId.value = userId;

      // Optional: fetch the latest profile from the backend
      await userController.fetchUserProfile();

      // Determine destination based on role
      final role = prefs.getString('user_role') ?? 'trainee';
      _nextRoute = (role == 'admin') ? AppRoutes.adminReport : AppRoutes.main;
    } else {
      // No saved session → go to welcome screen
      _nextRoute = AppRoutes.welcome;
    }
    _sessionChecked = true;
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

    // --- Wait for the session check to finish (should already be done) ---
    while (!_sessionChecked) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // --- Navigate to the determined route ---
    if (mounted) {
      Get.offNamed(_nextRoute!);
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
        decoration: const BoxDecoration(
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
        return const SizedBox.shrink();
    }
  }

  Widget _buildGlowingMapPin() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(
                      0xFF00D9B5,
                    ).withValues(alpha: 0.5 + _glowController.value * 0.3),
                    const Color(
                      0xFF00D9B5,
                    ).withValues(alpha: 0.2 + _glowController.value * 0.2),
                    const Color(0xFF00D9B5).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            Image.asset(
              'assets/images/splash1.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
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
// Custom Painters (unchanged)
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

    canvas.drawCircle(Offset(cx - 30, cy - 70), 28, paint);

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

class GradientBorderCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const double strokeWidth = 2.0;
    final double radius = size.width / 2;

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

// ------------------------------------------------------------
// Welcome Screen (unchanged)
// ------------------------------------------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0A5848), Color(0xFF09FACA)],
                      stops: [0.0, 1.0],
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.onboarding),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9B5),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: const Color(
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () => Get.toNamed(AppRoutes.login),
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
// Onboarding Data Model (unchanged)
// ------------------------------------------------------------
class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });
}

// ------------------------------------------------------------
// Onboarding Screen (unchanged)
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
      title: 'Martial Arts for All',
      subtitle: 'Learn How To Make Martial Arts Inclusive For Everyone',
      description: '',
      imagePath: 'assets/images/onboarding1.png',
    ),
    OnboardingData(
      title: 'Inclusive Practice',
      subtitle: '',
      description:
          'The MAPPED application has a specific purpose. It helps coaches to implement inclusive practice. We focus on grassroots sessions within traditional martial arts. Our primary goal is clear. We want to make martial arts accessible to all participants. You must understand these principles first. Therefore, we strongly advise you to complete our online learning modules. You should finish these educational materials before you start using the application. These modules teach you how to adapt your training methods. They will help you to accommodate diverse needs and abilities in your classes.',
      imagePath: 'assets/images/onboarding3.png',
    ),
    OnboardingData(
      title: 'Apply Your Knowledge',
      subtitle: '',
      description:
          'The app provides practical tools to support your inclusive coaching. The app allows you to track your personal certification progress, provides a daily recommendation to guide your coaching focus, plan training sessions, manage your participant lists, access training resources, discuss strategies with other coaches in the forum and access the AI Coach Bot for immediate advice on inclusive techniques. You are now ready to register and begin.',
      imagePath: 'assets/images/resource2.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular image with gradient border
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(-0.71, -0.71),
                end: Alignment(0.71, 0.71),
                colors: [
                  Color(0xFF00FFA6),
                  Color(0xFFA77CBE),
                  Color(0xFF6FA8C3),
                  Color(0xFF09FACA),
                ],
                stops: [0.1485, 0.3462, 0.5743, 0.8531],
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: Image.asset(
                data.imagePath,
                width: 254,
                height: 254,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1a2a3a),
                  child: Icon(
                    Icons.sports_martial_arts,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            data.title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // Subtitle – only on first screen
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              data.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Description – screens 2 and 3
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              data.description,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          // Hint text
          Text(
            'Visit our online course to learn more about\ninclusive practice in martial arts.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Online Learning pill – display only, no external link
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Online Learning',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          _buildIndicators(),
          const SizedBox(height: 16),
          if (_currentPage == _pages.length - 1)
            Center(child: _buildRegisterButton())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNextButton(),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _pages.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
      height: 46,
      width: 160,
      child: ElevatedButton(
        onPressed: () => Get.toNamed(AppRoutes.register),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF00D9B5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF00D9B5), width: 1.5),
          ),
        ),
        child: Text(
          'Register',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00D9B5),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      height: 46,
      width: 160,
      child: ElevatedButton(
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF00D9B5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF00D9B5), width: 1.5),
          ),
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00D9B5),
          ),
        ),
      ),
    );
  }
}