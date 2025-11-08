import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'login_binding.dart';
import '../screens/splash_screen.dart';
import '../screens/verification_code_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String verification = '/verification';
  static const String resetPassword = '/reset_password'; 
  static const String home = '/home';
}

class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationCodeScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
  ];
}