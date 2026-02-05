import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextSizeController extends GetxController {
  // 1.0 is normal size. Range will be 0.8 to 1.4
  var textScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedTextScale();
  }

  Future<void> loadSavedTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    textScale.value = prefs.getDouble('text_scale') ?? 1.0;
  }

  Future<void> updateTextScale(double value) async {
    textScale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', value);
  }
}