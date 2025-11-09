import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileEditorController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController(text: 'Nur Ain Binti Ibrahim');
  final nicknameController = TextEditingController(text: 'nur.ain');
  final emailController = TextEditingController(text: 'youremail@domain.com');
  final phoneController = TextEditingController(text: '123-456-7890');
  final addressController = TextEditingController(
    text: '45 Jalan 197, Skudai, Johor, Malaysia',
  );

  // Add reactive variables for display
  var displayName = 'Lieyza'.obs;
  var displayEmail = 'youremail@domain.com'.obs;
  var displayPhone = '123-456-7890'.obs;

  var selectedCountry = 'Malaysia'.obs;
  var selectedGender = 'Female'.obs;

  // Fix the asset path - remove the duplicate 'assets/'
  var profileImage = 'assets/images/profile_picture.png'.obs;

  final countries = [
    'Malaysia',
    'Singapore',
    'Indonesia',
    'Thailand',
    'Philippines',
  ];
  final genders = ['Male', 'Female'];

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes and update reactive variables
    nameController.addListener(() {
      displayName.value = nameController.text;
    });
    emailController.addListener(() {
      displayEmail.value = emailController.text;
    });
    phoneController.addListener(() {
      displayPhone.value = phoneController.text;
    });
  }

  void saveProfile() {
    if (formKey.currentState!.validate()) {
      // Save profile logic here
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF09FACA),
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  void cancel() {
    Get.back();
  }

  void changeProfilePicture() {
    // Implement image picker logic
    Get.snackbar(
      'Info',
      'Image picker will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
