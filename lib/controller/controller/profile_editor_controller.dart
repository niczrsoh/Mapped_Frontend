import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileEditorController extends GetxController {
  final Map<dynamic, dynamic>? userData;
  
  ProfileEditorController({this.userData});

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Reactive variables for display
  var displayName = ''.obs;
  var displayEmail = ''.obs;
  var displayPhone = ''.obs;

  var selectedCountry = 'Malaysia'.obs;
  var selectedGender = 'Female'.obs;

  // Profile image
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
    
    // Initialize with user data if provided
    if (userData != null) {
      _initializeWithUserData(userData!);
    }
    
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

  void _initializeWithUserData(Map<dynamic, dynamic> data) {
    print('Initializing profile editor with user data: $data');
    
    // Helper function to safely get string values from dynamic map
    String getStringValue(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }
    
    // Set text controllers with actual user data
    nameController.text = getStringValue(data['name']);
    emailController.text = getStringValue(data['email']);
    
    // Set nickname - use username if available, otherwise use first part of email
    final username = getStringValue(data['username']);
    if (username.isNotEmpty) {
      nicknameController.text = username;
    } else if (emailController.text.isNotEmpty) {
      nicknameController.text = emailController.text.split('@').first;
    } else {
      nicknameController.text = getStringValue(data['nickname']);
    }
    
    // Set other fields if available
    phoneController.text = getStringValue(data['phone']) != '' 
        ? getStringValue(data['phone']) 
        : '123-456-7890';
    
    addressController.text = getStringValue(data['address']) != ''
        ? getStringValue(data['address'])
        : '45 Jalan 197, Skudai, Johor, Malaysia';
    
    selectedCountry.value = getStringValue(data['country']) != ''
        ? getStringValue(data['country'])
        : 'Malaysia';
    
    selectedGender.value = getStringValue(data['gender']) != ''
        ? getStringValue(data['gender'])
        : 'Female';
    
    // Set profile image - check if it's a URL or local path
    final avatar = getStringValue(data['avatar']);
    if (avatar.isNotEmpty) {
      // Check if it's a full URL or relative path
      if (avatar.startsWith('http')) {
        profileImage.value = avatar;
      } else if (avatar.startsWith('uploads/')) {
        // Assuming your backend serves images from uploads folder
        profileImage.value = 'http://10.0.2.2:5000/$avatar'; // For Android emulator
        // For iOS: 'http://localhost:5000/$avatar'
        // For real device: 'http://your-server-ip:5000/$avatar'
      } else {
        profileImage.value = avatar;
      }
    }
    
    // Update display values
    displayName.value = nameController.text.isNotEmpty 
        ? nameController.text 
        : 'User';
    displayEmail.value = emailController.text.isNotEmpty
        ? emailController.text
        : 'youremail@domain.com';
    displayPhone.value = phoneController.text.isNotEmpty
        ? phoneController.text
        : '123-456-7890';
    
    print('Profile editor initialized successfully');
    print('Name: ${nameController.text}');
    print('Email: ${emailController.text}');
    print('Phone: ${phoneController.text}');
    print('Country: ${selectedCountry.value}');
    print('Gender: ${selectedGender.value}');
    print('Avatar: ${profileImage.value}');
  }

  void saveProfile() {
    if (formKey.currentState!.validate()) {
      // Save profile logic here
      // In a real app, you would make an API call to update the user profile
      
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
    // For now, we'll just show a snackbar
    // In a real app, you would use image_picker package
    Get.snackbar(
      'Coming Soon',
      'Image picker will be implemented in the next update',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    
    // Uncomment this when you implement image picker:
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   // Upload the image via API
    //   // Update local image
    //   profileImage.value = pickedFile.path;
    // }
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