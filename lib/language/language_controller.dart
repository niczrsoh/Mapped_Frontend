import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var currentLanguage = 'en'.obs;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'French', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'German', 'code': 'de', 'flag': '🇩🇪'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  // Load saved language from storage (sync currentLanguage with prefs only)
  // EasyLocalization restores its own locale automatically at startup.
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code') ?? 'en';
    currentLanguage.value = savedCode;
  }

  // Change and save language
  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    currentLanguage.value = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    // Apply locale change — triggers EasyLocalization to rebuild its subtree,
    // which calls _AppRootState.build, which pushes the new locale to GetMaterialApp
    await context.setLocale(Locale(languageCode));

    // Wait one frame for the locale rebuild to propagate before navigating away
    await Future.delayed(const Duration(milliseconds: 100));

    Get.back();

    Get.snackbar(
      "lang_ctrl_snackbar_title".tr(),
      "lang_ctrl_snackbar_msg".tr(
        namedArgs: {'name': _getLanguageName(languageCode)},
      ),
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  String _getLanguageName(String code) {
    return languages.firstWhere((element) => element['code'] == code)['name']!;
  }
}
