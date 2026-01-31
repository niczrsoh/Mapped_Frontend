import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //-----------------end----------------------------
  final String baseUrl = "http://10.0.2.2:5000/api";

  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
        final String errorMsg =
            responseBody['msg'] ??
            'Registration failed with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during registration: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  Future<Map<String, dynamic>> registerUserWithGoogle({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    final url = Uri.parse('$baseUrl/users/google-register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'provider': 'google', // Important to identify auth provider
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store token if your backend returns one
        if (responseBody.containsKey('token')) {
          // Save token to local storage (e.g., SharedPreferences)
        }
        return {'success': true, 'data': responseBody};
      } else {
        final String errorMsg =
            responseBody['msg'] ??
            'Google registration failed with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during Google registration: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  // LOGIN METHOD - Add this
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody};
      } else {
        final String errorMsg =
            responseBody['msg'] ??
            responseBody['message'] ??
            'Login failed with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during login: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  // GET USER PROFILE
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final url = Uri.parse('$baseUrl/profile/$userId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get Profile Response Status: ${response.statusCode}');
      print('Get Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String errorMsg =
            responseBody['msg'] ??
            'Failed to load profile with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during profile fetch: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }
}
