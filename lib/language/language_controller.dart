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

  // Load saved language from storage
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage.value = prefs.getString('language_code') ?? 'en';
    // Here you would also update the app's locale if using localization
    // Get.updateLocale(Locale(currentLanguage.value));
  }

  // Change and save language
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    // Update app locale (if you are using GetX localization)
    // Get.updateLocale(Locale(languageCode));

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
