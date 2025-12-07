import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use the correct URL: http://10.0.2.2:5000 (Android) or http://localhost:5000 (iOS/Local)
  final String baseUrl = "https://mapped-backend-node-js.onrender.com/api/users"; 

  Future<Map<String, dynamic>> registerUser({
    required String fullName, 
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': fullName, 
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': responseBody};
      } else {
        final String errorMsg = responseBody['msg'] ?? 'Registration failed with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during registration: $e');
      return {'success': false, 'error': 'Network Error. Check server connection.'};
    }
  }
}