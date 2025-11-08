import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/check_mail_screen.dart';
import '../screens/touch_id_screen.dart';
import '../controller/controller/register_controller.dart';
import 'login_binding.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String touchId = '/touch_id';
  static const String resetPassword = '/reset_password';

  static const String checkMail = '/check_mail';
  static const String home = '/home';
}

class AppPages {
  static final List<GetPage> routes = <GetPage>[
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
  ];
}
