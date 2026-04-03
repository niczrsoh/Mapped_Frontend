import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapped_frontend/account/account_controller.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/controller/bottom_nav_controller.dart';
import 'package:mapped_frontend/screens/home_screen.dart';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:mapped_frontend/text_size/text_size_controller.dart';
import 'global/app_binding.dart';
import 'global/routes.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = ApiService();
  service.validateServer();

  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  Get.put(TextSizeController());
  Get.put(BottomNavController(), permanent: true);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('de'), Locale('es'), Locale('hr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    Get.put(AccountController());

    return _AppRoot();
  }
}

class _AppRoot extends StatefulWidget {
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  Locale? _lastLocale;

  @override
  Widget build(BuildContext context) {
    final newLocale = context.locale;

    // Only push to GetMaterialApp when the locale actually changed
    if (_lastLocale != newLocale) {
      _lastLocale = newLocale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.updateLocale(newLocale);
      });
    }

    return GetMaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: newLocale,
      title: 'MAPPED',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      theme: ThemeData(
        primaryColor: const Color(0xFF00D9B5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D9B5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1a1f2e),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: (context, child) => ScaledMediaQuery(child: child!),
    );
  }
}

class ScaledMediaQuery extends StatelessWidget {
  final Widget child;

  const ScaledMediaQuery({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final TextSizeController textSizeController =
        Get.find<TextSizeController>();

    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textSizeController.textScale.value),
        ),
        child: child,
      ),
    );
  }
}
