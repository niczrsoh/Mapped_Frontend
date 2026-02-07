import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/help_support/help_support_model.dart';

class HelpSupportController extends GetxController {
  // Configuration
  final String baseUrl = kIsWeb
      ? "http://localhost:5000"
      : "http://10.0.2.2:5000";

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable state
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var showSuccessDialog = false.obs;
  var tickets = <SupportTicket>[].obs;

  // Get UserController instance
  UserController get userController => Get.find<UserController>();

  // Get user ID
  String get userId {
    final userData = userController.userData.value;
    return userData['_id'] ?? userData['id'] ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    // Load user's tickets
    fetchUserTickets();
  }

  // Validate form
  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title for your issue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please describe your problem',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (descriptionController.text.trim().length < 10) {
      Get.snackbar(
        'Error',
        'Please provide more details (at least 10 characters)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Submit support ticket
  Future<bool> submitTicket() async {
    if (!validateForm()) return false;

    if (userId.isEmpty) {
      Get.snackbar(
        'Error',
        'User not logged in',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      final ticket = SupportTicket(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        userId: userId,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/support/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ticket.toJson()),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Handle both response formats
        SupportTicket createdTicket;
        if (responseData['success'] == true && responseData['data'] != null) {
          createdTicket = SupportTicket.fromJson(responseData['data']);
        } else if (responseData['ticket'] != null) {
          createdTicket = SupportTicket.fromJson(responseData['ticket']);
        } else {
          createdTicket = SupportTicket.fromJson(responseData);
        }

        // Add to local list
        tickets.insert(0, createdTicket);

        // Clear form
        titleController.clear();
        descriptionController.clear();

        // Show success dialog
        showSuccessDialog.value = true;

        return true;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Failed to submit ticket';
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error submitting ticket: $e');
      Get.snackbar(
        'Error',
        'Connection error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Fetch user's tickets
  Future<void> fetchUserTickets() async {
    if (userId.isEmpty) return;

    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/support/tickets/user/$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        List<dynamic> ticketsData;
        if (responseData['success'] == true && responseData['data'] != null) {
          ticketsData = responseData['data'];
        } else if (responseData['tickets'] != null) {
          ticketsData = responseData['tickets'];
        } else if (responseData is List) {
          ticketsData = responseData;
        } else {
          ticketsData = [];
        }

        tickets.value = ticketsData
            .map((json) => SupportTicket.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Close success dialog and reset form
  void closeSuccessDialog() {
    showSuccessDialog.value = false;
  }

  // Navigate to contact email
  void contactSupport() {
    // You can implement email launch or other contact methods
    Get.snackbar(
      'Contact Support',
      'Email: info@insideeu.eu',
      backgroundColor: Color(0xFF09FACA),
      colorText: Color(0xFF1A1D29),
      duration: Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}