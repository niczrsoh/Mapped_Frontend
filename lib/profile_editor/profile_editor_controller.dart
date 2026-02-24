import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'profile_editor_model.dart';

class ProfileEditorController extends GetxController {
  // Configuration
  final String baseUrl = kIsWeb
      ? "http://localhost:5000"
      : "https://mapped-backend-node-js.onrender.com";

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Observable state
  var userProfile = Rx<UserProfile?>(null);
  var isLoading = false.obs;
  var isSaving = false.obs;
  var selectedCountry = 'Malaysia'.obs;
  var selectedGender = 'Female'.obs;
  var profileImage = ''.obs;
  var selectedImageFile = Rx<XFile?>(null);

  // Static data
  final List<String> countries = [
    'Malaysia',
    'Singapore',
    'Indonesia',
    'Thailand',
    'Philippines',
    'Vietnam',
    'Brunei',
    'Myanmar',
    'Cambodia',
    'Laos',
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Get UserController instance
  UserController get userController => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    // Will be initialized from screen with user data
  }

  // Initialize with user data
  void initializeWithUserData(Map<dynamic, dynamic>? userData) {
    if (userData == null) return;

    try {
      // Convert dynamic map to String map
      final Map<String, dynamic> data = userData.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      // Create user profile model
      userProfile.value = UserProfile.fromJson(data);

      // Populate text controllers
      nameController.text = userProfile.value!.name;
      usernameController.text = userProfile.value!.username;
      emailController.text = userProfile.value!.email;
      phoneController.text = userProfile.value!.phone;
      addressController.text = userProfile.value!.address;

      // Set dropdown values
      selectedCountry.value = userProfile.value!.country;
      selectedGender.value = userProfile.value!.gender;

      // Set profile image
      profileImage.value = userProfile.value!.getFullAvatarUrl(baseUrl);

      print('Profile editor initialized successfully');
      print('User: ${userProfile.value!.name}');
    } catch (e) {
      print('Error initializing profile editor: $e');
      Get.snackbar('Error', 'Failed to load profile data');
    }
  }

  // Get current user data as UserProfile
  UserProfile getCurrentProfileData() {
    return UserProfile(
      id: userProfile.value?.id ?? '',
      name: nameController.text.trim(),
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      country: selectedCountry.value,
      gender: selectedGender.value,
      avatar: userProfile.value?.avatar ?? '',
    );
  }

  // Validate form
  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return false;
    }

    return true;
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Pick profile image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = image;
        // For preview, use the local file path
        if (kIsWeb) {
          profileImage.value = image.path;
        } else {
          profileImage.value = image.path;
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  // Pick profile image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = image;
        profileImage.value = image.path;
      }
    } catch (e) {
      print('Error taking photo: $e');
      Get.snackbar('Error', 'Failed to take photo');
    }
  }

  // Save profile to backend
  Future<bool> saveProfile() async {
    if (!validateForm()) return false;

    isSaving.value = true;

    try {
      final userId = userProfile.value?.id;
      if (userId == null || userId.isEmpty) {
        Get.snackbar('Error', 'User ID not found');
        return false;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/profile/$userId'),
      );

      // Add text fields
      request.fields['name'] = nameController.text.trim();
      request.fields['username'] = usernameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['address'] = addressController.text.trim();
      request.fields['country'] = selectedCountry.value;
      request.fields['gender'] = selectedGender.value;

      // Add image if selected
      if (selectedImageFile.value != null) {
        if (kIsWeb) {
          var bytes = await selectedImageFile.value!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: selectedImageFile.value!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'avatar',
              selectedImageFile.value!.path,
            ),
          );
        }
      }

      print('Updating profile for user: $userId');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        
        // Handle both response formats
        Map<String, dynamic> userData;
        if (responseData['success'] == true && responseData['data'] != null) {
          // New format: {success: true, data: {...}}
          userData = responseData['data'];
        } else if (responseData['_id'] != null) {
          // Old format: direct user object
          userData = responseData;
        } else {
          Get.snackbar('Error', 'Invalid response format');
          return false;
        }
        
        // Update local user profile
        userProfile.value = UserProfile.fromJson(userData);
        
        // Refresh UserController data to update account page
        await userController.fetchUserProfile();
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        final error = jsonDecode(responseBody);
        final errorMessage = error['message'] ?? 'Failed to update profile';
        Get.snackbar('Error', errorMessage);
        return false;
      }
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar('Error', 'Connection error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}