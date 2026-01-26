import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'global/app_binding.dart';
import 'global/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase without options (for testing)
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
    );
  }
}