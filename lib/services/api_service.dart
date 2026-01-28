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

  // ADD THIS METHOD FOR TRAINEE
  Future<Map<String, dynamic>> addTrainee({
    required String name,
    required String belt,
    required String dateOfBirth,
    required String gender,
    required String phone,
    required String email,
    required String address,
    required String guardianName,
    required String guardianContact,
    required String guardianAddress,
    String? imagePath,
  }) async {
    final url = Uri.parse('$baseUrl/trainee'); // Uses /trainee endpoint

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': name,
          'belt': belt,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'phone': phone,
          'email': email,
          'address': address,
          'guardianName': guardianName,
          'guardianContact': guardianContact,
          'guardianAddress': guardianAddress,
          'image': imagePath,
        }),
      );

      print('Trainee API Response Status: ${response.statusCode}');
      // print('Trainee API Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': responseBody};
      } else {
        final String errorMsg =
            responseBody['msg'] ??
            'Failed to add trainee with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during trainee creation: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  // === ADD THIS METHOD FOR GETTING TRAINEES ===
  Future<Map<String, dynamic>> getAllTrainees() async {
    final url = Uri.parse(
      '$baseUrl/trainee',
    ); // Assuming endpoint is /api/trainee

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get Trainees API Response Status: ${response.statusCode}');
      //print('Get Trainees API Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          //'trainees': responseBody['trainees'] ?? responseBody['data'] ?? [],
          // 2. Fixed Data mapping: Node.js returns 'data', not 'trainees'
          'data': responseBody['data'] ?? [],
        };
      } else {
        final String errorMsg =
            responseBody['msg'] ??
            'Failed to fetch trainees with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during fetching trainees: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  // === END OF ADDED METHOD ===

  Future<Map<String, dynamic>> updateTrainee(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/trainee/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );

      print('Update Trainee Status: ${response.statusCode}');
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody['data']};
      } else {
        return {
          'success': false,
          'error': responseBody['msg'] ?? 'Update failed',
        };
      }
    } catch (e) {
      print('API Update Error: $e');
      return {'success': false, 'error': 'Network Error'};
    }
  }

  // --- DELETE TRAINEE ---
  Future<Map<String, dynamic>> deleteTrainee(String id) async {
    final url = Uri.parse('$baseUrl/trainee/$id');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Delete Trainee Status: ${response.statusCode}');
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': responseBody['msg'] ?? 'Delete failed',
        };
      }
    } catch (e) {
      print('API Delete Error: $e');
      return {'success': false, 'error': 'Network Error'};
    }
  }
  // 👇 PASTE THIS NEW FUNCTION HERE (Inside the class) 👇

  Future<Map<String, dynamic>> createSession({
    required String trainer,
    required String date,
    required String startTime, // New Param
    required String endTime, // New Param
    required String venue,
    required String totalTrainees,
  }) async {
    try {
      // 1. Point to the new session route
      final url = Uri.parse('$baseUrl/session');

      // 2. Encode the data
      // We send strings for date/time because your backend parses them
      final body = jsonEncode({
        "trainer": trainer,
        "date": date, // "Wed, Sept 21, 2025"
        "startTime": startTime, // "6:00 PM"
        "endTime": endTime, // "7:00 PM"
        "venue": venue,
        "totalTrainees": totalTrainees,
      });

      // 3. Send POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final responseData = jsonDecode(response.body);

      // 4. Handle Success
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'msg': responseData['msg'],
          'data': responseData['data'],
        };
      }
      // 5. Handle Validation Errors from Backend
      else {
        return {
          'success': false,
          'msg': responseData['msg'] ?? 'Failed to create session',
          'error': responseData['errors'],
        };
      }
    } catch (e) {
      print("API Create Session Error: $e");
      return {'success': false, 'msg': 'Connection Error: $e'};
    }
  }

  // Fetch Dashboard Data (Current, Upcoming, History)
  Future<Map<String, dynamic>> getSessionDashboard() async {
    try {
      // Ensure this matches your backend route
      final url = Uri.parse('$baseUrl/session/dashboard');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'msg': 'Failed to load dashboard: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("API Dashboard Error: $e");
      return {'success': false, 'msg': 'Connection Error: $e'};
    }
  }

  // Update an existing session
  Future<Map<String, dynamic>> updateSession({
    required String id,
    required String trainer,
    required String date,
    required String startTime, // New Param
    required String endTime, // New Param
    required String venue,
    required String totalTrainees,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/session/$id'); // PUT endpoint with ID

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trainer': trainer,
          'date': date,
          'startTime': startTime, // Sending ISO String
          'endTime': endTime, // Sending ISO String
          'venue': venue,
          'totalTrainees': totalTrainees,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody['data']};
      } else {
        return {
          'success': false,
          'msg': responseBody['msg'] ?? 'Failed to update session',
        };
      }
    } catch (e) {
      print("API Update Session Error: $e");
      return {'success': false, 'msg': 'Connection Error: $e'};
    }
  }

  // ... inside ApiService class

  // --- PROGRESS ENDPOINTS ---

  Future<Map<String, dynamic>> saveProgress(Map<String, dynamic> data) async {
    try {
      // Assuming your baseUrl is set up correctly in the class
      final response = await http.post(
        Uri.parse(
          '$baseUrl/progress',
        ), // Ensure /progress route is added to your server.js
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProgress(
    String traineeId,
    String form,
  ) async {
    try {
      // Encode form because it contains spaces and brackets
      final encodedForm = Uri.encodeComponent(form);
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$traineeId/$encodedForm'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // GET ALL PROGRESS FOR A TRAINEE (For Dashboard Average)
  Future<Map<String, dynamic>> getAllProgress(String traineeId) async {
    try {
      // Use the specific traineeId endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$traineeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'msg': 'Failed to fetch progress: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Connection error: $e'};
    }
  }

  // ==================================================
  // GET ALL BELT RINGS (Calculated Average for Dashboard)
  // ==================================================
  Future<Map<String, dynamic>> getBeltRings() async {
    try {
      // Make sure this matches the route defined in your Node.js backend
      final response = await http.get(
        Uri.parse('$baseUrl/belt-progress'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'msg': 'Failed to fetch belt rings. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Error fetching belt rings: $e");
      return {'success': false, 'msg': e.toString()};
    }
  }

  // ==================================================
  // 2. NEW RESOURCE METHODS (For Social Feed)
  // ==================================================

  Future<Map<String, dynamic>> getAllResources({
    String type = 'All',
    String? tag,
    String? search,
  }) async {
    String url = '$baseUrl/resource';
    List<String> params = [];

    // Add filters to list
    if (type != 'All') {
      params.add('type=$type');
    }
    if (tag != null && tag.isNotEmpty) {
      params.add('tag=$tag');
    }
    if (search != null && search.isNotEmpty)
      params.add('search=$search'); // <--- Add this line

    // Join params with & and append to URL
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    return await _get(url);
  }

  // Get All Unique Tags (NEW METHOD)
  Future<Map<String, dynamic>> getTags() async {
    // This calls the new backend route: router.get('/tags', ...)
    return await _get('$baseUrl/resource/tags');
  }

  // Add Resource
  Future<Map<String, dynamic>> addResource({
    required String title,
    required String type,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? linkUrl,
    required String author,
    required String description,
  }) async {
    final body = {
      "title": title,
      "type": type,
      "imageUrls": imageUrls ?? [],
      "videoUrls": videoUrls ?? [],
      "linkUrl": linkUrl ?? "",
      "author": author,
      "description": description,
    };
    return await _post(
      '$baseUrl/resource',
      body,
    ); // Requires _post helper below
  }

  // Delete Resource
  Future<Map<String, dynamic>> deleteResource(String id) async {
    return await _delete(
      '$baseUrl/resource/$id',
    ); // Requires _delete helper below
  }

  // ==================================================
  // 3. PRIVATE HELPER METHODS (FIXES YOUR ERRORS)
  // ==================================================

  // Helper: GET Request
  Future<Map<String, dynamic>> _get(String urls) async {
    try {
      final response = await http.get(
        Uri.parse(urls),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  // Helper: POST Request
  Future<Map<String, dynamic>> _post(
    String urls,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(urls),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  // Helper: PUT Request (If needed for resources later)
  Future<Map<String, dynamic>> _put(
    String urls,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(urls),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  // Helper: DELETE Request
  Future<Map<String, dynamic>> _delete(String urls) async {
    try {
      final response = await http.delete(
        Uri.parse(urls),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  // Helper: Process HTTP Response
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedBody is Map<String, dynamic> ? decodedBody : {};
      } else {
        return {
          'success': false,
          'msg':
              decodedBody['msg'] ??
              decodedBody['error'] ??
              'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Failed to parse server response'};
    }
  }
} // <---
