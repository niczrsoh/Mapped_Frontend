import 'package:get/get.dart';
import 'package:mapped_frontend/admin/admin_main_screen.dart';
import 'package:mapped_frontend/coachBot/coachBot_controller.dart';
import 'package:mapped_frontend/coachBot/coachBot_screen.dart';
import 'package:mapped_frontend/forum/forum_screen.dart';
import 'package:mapped_frontend/screens/main_navigation_screen.dart';
import 'package:mapped_frontend/session/session_dashboard_screen.dart';
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
import '../account/account_screen.dart';
import '../account/account_controller.dart';
import '../profile_editor/profile_editor_screen.dart';
import '../profile_editor/profile_editor_controller.dart';
import '../screens/notification_screen.dart';
import '../forum_searchtags/forum_searchtags_screen.dart';
import '../forum/forum_controller.dart';
import '../create_post/create_post_screen.dart';

class AppRoutes {
  //chatbot
  static const String coachBotHealth = '/health';
  static const String coachBot = '/coach-bot';
  static const String coachBotChat = '/chat';

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
  static const String security = '/security';

  static const String bottomNav = '/bottom-nav';
  static const String forum = '/forum';
  static const String forumSearchTags = '/forum-search-tags';
  static const String createPost = '/create-post';
  static const String session = '/session';
  static const main = '/main';
  static const String verificationCode = '/verification_code';
  static const String adminReport = '/admin-report';
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
    GetPage(name: AppRoutes.bottomNav, page: () => const BottomNav()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.touchId, page: () => const TouchIdScreen()),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
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
      page: () => AccountScreen(),
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
    GetPage(name: AppRoutes.notification, page: () => NotificationScreen()),
    GetPage(
      name: AppRoutes.forum, 
      page: () => ForumScreen(),
      binding: BindingsBuilder(() {
        Get.put(ForumController());
      }),
    ),
      GetPage(
      name: AppRoutes.coachBot,
      page: () => CoachBotScreen(),
      binding: BindingsBuilder(() {
        Get.put(CoachBotController());
      }),
    ),
    GetPage(name: AppRoutes.session, page: () => SessionDashboardScreen()),
    GetPage(name: AppRoutes.main, page: () => const MainNavigationScreen()),
    GetPage(name: AppRoutes.forumSearchTags, page: () => ForumSearchtagsScreen()),
    GetPage(name: AppRoutes.createPost, page: () => CreatePostScreen()),
    GetPage(
      name: AppRoutes.verificationCode,
      page: () => const VerificationCodeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminReport, 
      page: () => AdminMainScreen(),
      transition: Transition.native,
    ),
  ];
}