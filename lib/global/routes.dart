import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import '../screens/create_new_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/check_mail_screen.dart';
import '../screens/touch_id_screen.dart';
import '../controller/controller/register_controller.dart';
import 'login_binding.dart';
import '../screens/splash_screen.dart';
import '../screens/verification_code_screen.dart';
import '../screens/account_screen.dart';
import '../controller/controller/account_controller.dart';
import '../screens/profile_editor_screen.dart';
import '../controller/controller/profile_editor_controller.dart';
import '../screens/notification_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String touchId = '/touch_id';
  static const String resetPassword = '/reset_password';

  static const String checkMail = '/check_mail';
  static const String verification = '/verification';
  static const String createNewPassword = '/create_new_password';
  static const String home = '/home';
  static const String account = '/account';
  static const String editProfile = '/edit-profile';
  static const String notification = '/notification';
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
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.touchId, page: () => const TouchIdScreen()),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      // Provide the RegisterController when navigating to the register page
      binding: BindingsBuilder(() {
        Get.put(RegisterController());
      }),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(name: AppRoutes.checkMail, page: () => const CheckMailScreen()),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationCodeScreen(),
    ),
    GetPage(
      name: AppRoutes.createNewPassword,
      page: () => const CreateNewPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.account, 
      page: () => AccountPage(),
      binding: BindingsBuilder(() {
        Get.put(AccountController());
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => ProfileEditorScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProfileEditorController());
      }),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => NotificationScreen(),
    ),
  ];
}
