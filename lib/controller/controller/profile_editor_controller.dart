import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapped_frontend/controller/controller/account_controller.dart';

class ProfileEditorController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final String baseUrl = kIsWeb
      ? "http://localhost:5000" // If Chrome: Use localhost
      : "http://10.0.2.2:5000"; // If Android Emulator: Use 10.0.2.2
  // Note: If using a real physical phone, replace 10.0.2.2 with IP address
  final String userId = "692a8a206881c040ebf00943";

  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Add reactive variables for display
  var displayName = 'User'.obs;
  var displayEmail = 'email@domain.com'.obs;
  var displayPhone = '000-000-0000'.obs;

  var isLoading = false.obs; // To show loading spinners
  var profileImageUrl = ''.obs; // Stores the URL from backend

  var selectedCountry = 'Malaysia'.obs;
  var selectedGender = 'Female'.obs;

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

    nameController.addListener(() {
      displayName.value = nameController.text;
    });
    emailController.addListener(() {
      displayEmail.value = emailController.text;
    });
    phoneController.addListener(() {
      displayPhone.value = phoneController.text;
    });

    fetchUserProfile(); // <--- Load data when controller starts
  }

  // 1. FETCH USER PROFILE (GET)
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/api/profile/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!isClosed) {
          // Update Text Controllers
          nameController.text = data['name'] ?? '';
          nicknameController.text = data['username'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';

          // Update Dropdowns
          if (data['country'] != null) selectedCountry.value = data['country'];
          if (data['gender'] != null) selectedGender.value = data['gender'];

          // Update Profile Image URL
          // Backend returns "uploads/user-123.jpg". We need to add the base URL.
          if (data['avatar'] != null && data['avatar'] != "") {
            profileImageUrl.value = "$baseUrl/${data['avatar']}";
          }
        }

      } else {
        Get.snackbar("Error", "Failed to load profile");
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      Get.snackbar("Error", "Could not connect to server");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. SAVE TEXT DATA (PUT)
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/api/profile/$userId');

      final body = jsonEncode({
        "name": nameController.text,
        "username": nicknameController.text,
        "phone": phoneController.text,
        "country": selectedCountry.value,
        "gender": selectedGender.value,
        "address": addressController.text,
        // We usually don't update email here, but you can if your backend allows it
      });

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: const Color(0xFF09FACA),
          colorText: Colors.white,
        );

        if (Get.isRegistered<AccountController>()) {
          Get.find<AccountController>().refreshProfile();
        }
  
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true); // Pass true to indicate profile was updated
        });
      } else {
        Get.snackbar("Error", "Update failed: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  // 3. UPLOAD IMAGE (PUT Multipart)
  Future<void> changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return; // User cancelled

    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/api/profile/picture/$userId');

      // Create Multipart Request
      var request = http.MultipartRequest('PUT', uri);

      // Add the file (Key must be 'profileImage' to match your backend)
      var multipartFile = await http.MultipartFile.fromPath(
        'profileImage',
        image.path,
      );
      request.files.add(multipartFile);

      // Send Request
      var streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update the UI immediately with the new image
        if (data['avatar'] != null) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          profileImageUrl.value = "$baseUrl/${data['avatar']}?v=$timestamp";
          // Force UI refresh by adding a timestamp to URL if needed,
          // or just let GetX handle the observable change
        }

        Get.snackbar("Success", "Photo updated!");

        if (Get.isRegistered<AccountController>()) {
          Get.find<AccountController>().refreshProfile();
        }
      } else {
        Get.snackbar("Error", "Photo upload failed");
      }
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar("Error", "Could not upload photo");
    } finally {
      isLoading.value = false;
    }
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
