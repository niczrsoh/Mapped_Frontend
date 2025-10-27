import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'login_binding.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
}

class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
  ];
}