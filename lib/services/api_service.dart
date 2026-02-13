import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Participants/trainee_model.dart';
import '../session/session_model.dart';

class ApiService {
  //-----------------end----------------------------
  final String baseUrl = "https://mapped-backend-node-js-1.onrender.com/api";

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
  // GET USER PROFILE
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final url = Uri.parse('$baseUrl/profile/$userId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get Profile Response Status: ${response.statusCode}');

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

  Future<Map<String, dynamic>> addTrainee(TraineeModel trainee) async {
    final url = Uri.parse('$baseUrl/trainee');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['trainerId'] = trainee.trainerId ?? '';
      request.fields['name'] = trainee.name;
      request.fields['belt'] = trainee.belt;
      request.fields['dateOfBirth'] = trainee.dateOfBirth;
      request.fields['gender'] = trainee.gender;
      request.fields['phone'] = trainee.phone;
      request.fields['email'] = trainee.email;
      request.fields['address'] = trainee.address;
      request.fields['guardianName'] = trainee.guardianName;
      request.fields['guardianContact'] = trainee.guardianContact;
      request.fields['guardianAddress'] = trainee.guardianAddress;
      request.fields['goals'] = trainee.goals;
      request.fields['conditions'] = trainee.conditions;
      request.fields['competency'] = trainee.competency;

      // Add image file if exists
      if (trainee.imagePath != null && trainee.imagePath!.isNotEmpty) {
        final file = File(trainee.imagePath!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', trainee.imagePath!),
          );
          print('📎 Image attached: ${trainee.imagePath}');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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

  Future<Map<String, dynamic>> getAllTrainees() async {
    final url = Uri.parse('$baseUrl/trainee');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody['data'] ?? []};
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

  Future<Map<String, dynamic>> updateTrainee(
    String id,
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    final url = Uri.parse('$baseUrl/trainee/$id');

    try {
      var request = http.MultipartRequest('PUT', url);

      // Add all fields from data map
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath),
          );
          print('📎 New image attached: $imagePath');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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

  // --- TRAINER METHODS ---

  Future<Map<String, dynamic>> getAllTrainers() async {
    final url = Uri.parse('$baseUrl/trainer');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get Trainers API Response Status: ${response.statusCode}');

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody['data'] ?? []};
      } else {
        final String errorMsg =
            responseBody['msg'] ??
            'Failed to fetch trainers with status ${response.statusCode}';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('API Error during fetching trainers: $e');
      return {
        'success': false,
        'error': 'Network Error. Check server connection.',
      };
    }
  }

  Future<Map<String, dynamic>> getTrainerById(String id) async {
    final url = Uri.parse('$baseUrl/trainer/$id');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get Trainer($id) Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return {'success': true, 'data': responseBody['data'] ?? responseBody};
      } else {
        return {'success': false, 'error': 'Failed to load trainer'};
      }
    } catch (e) {
      print('API Error getting trainer: $e');
      return {'success': false, 'error': 'Network Error'};
    }
  }

  Future<Map<String, dynamic>> updateTrainer(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/trainer/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );

      print('Update Trainer Status: ${response.statusCode}');
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
      print('API Update Trainer Error: $e');
      return {'success': false, 'error': 'Network Error'};
    }
  }

  Future<Map<String, dynamic>> createSession(SessionModel session) async {
    try {
      final url = Uri.parse('$baseUrl/session');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(session.toJson()), // Send the Map directly
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'msg': responseData['msg'],
          'data': responseData['data'],
        };
      } else {
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

  Future<Map<String, dynamic>> getSessionDashboard({
    required String trainerId,
    required String trainerName,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/session/dashboard?trainerId=$trainerId&trainer=$trainerName',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return decodedBody;
      } else {
        return {
          'success': false,
          'msg': decodedBody['msg'] ?? 'Failed to load dashboard',
        };
      }
    } catch (e) {
      print("API Dashboard Error: $e");
      return {'success': false, 'msg': 'Connection Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateSession({
    required String id,
    String? trainerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/session/$id');

      if (trainerId != null) {
        data['trainerId'] = trainerId;
      }

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
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

  Future<Map<String, dynamic>> saveProgress(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/progress'),
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
    String beltColor,
    String form,
  ) async {
    try {
      final encodedForm = Uri.encodeComponent(form);
      final encodedBelt = Uri.encodeComponent(beltColor);

      final response = await http.get(
        Uri.parse('$baseUrl/progress/$traineeId/$encodedBelt/$encodedForm'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllProgress(
    String traineeId,
    String beltColor,
  ) async {
    try {
      final encodedBelt = Uri.encodeComponent(beltColor);

      final response = await http.get(
        Uri.parse('$baseUrl/progress/$traineeId/$encodedBelt'),
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

  Future<Map<String, dynamic>> deleteProgress(String traineeId) async {
    try {
      final url = Uri.parse('$baseUrl/progress/$traineeId');
      print('Attempting to delete progress at: $url');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'msg': 'Failed to delete progress: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Delete Progress Exception: $e');
      return {'success': false, 'msg': 'Connection error: $e'};
    }
  }

  // // ==================================================
  // // GET ALL BELT RINGS (Calculated Average for Dashboard)
  // // ==================================================
  // Future<Map<String, dynamic>> getBeltRings() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/belt-progress'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       return {
  //         'success': false,
  //         'msg': 'Failed to fetch belt rings. Status: ${response.statusCode}',
  //       };
  //     }
  //   } catch (e) {
  //     print("Error fetching belt rings: $e");
  //     return {'success': false, 'msg': e.toString()};
  //   }
  // }

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

    if (type != 'All') {
      params.add('type=$type');
    }
    if (tag != null && tag.isNotEmpty) {
      params.add('tag=$tag');
    }
    if (search != null && search.isNotEmpty) params.add('search=$search');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    return await _get(url);
  }

  Future<Map<String, dynamic>> getTags() async {
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
    return await _post('$baseUrl/resource', body);
  }

  Future<Map<String, dynamic>> deleteResource(String id) async {
    return await _delete('$baseUrl/resource/$id');
  }

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

  Future<Map<String, dynamic>> recordResourceView(
    String resourceId,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resources/$resourceId/view'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          '❌ Record view failed: ${response.statusCode} - ${response.body}',
        );
        return {'success': false, 'msg': 'Failed to record view'};
      }
    } catch (e) {
      print('❌ Record view error: $e');
      return {'success': false, 'msg': e.toString()};
    }
  }

  // Update this to accept userId
  Future<Map<String, dynamic>> getUserResourceProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resources/user/$userId/viewed'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Get resource progress failed: ${response.statusCode}');
        return {'success': false, 'data': []};
      }
    } catch (e) {
      print('❌ Get resource progress error: $e');
      return {'success': false, 'msg': e.toString(), 'data': []};
    }
  }

  Future<Map<String, dynamic>> updateBeltProgress({
    required String userId,
    required String beltColor,
    required String actionType,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/belt-progress/update');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'beltColor': beltColor,
          'actionType': actionType,
        }),
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': decodedBody['data']};
      } else {
        return {
          'success': false,
          'msg': decodedBody['msg'] ?? 'Failed to update belt progress',
        };
      }
    } catch (e) {
      print("API Update Belt Error: $e");
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchBeltProgress(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/belt-progress?userId=$userId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return decodedBody;
      } else {
        return {
          'success': false,
          'msg': decodedBody['msg'] ?? 'Failed to fetch belt progress',
        };
      }
    } catch (e) {
      print("API Fetch Belt Error: $e");
      return {'success': false, 'msg': 'Network Error: $e'};
    }
  }

  // Record reflection submission for belt progress tracking
  Future<Map<String, dynamic>> recordReflectionSubmission(
    String sessionId,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/$sessionId/reflection-submitted'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'msg': 'Failed to record reflection'};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // Get user's reflection submission history
  Future<Map<String, dynamic>> getUserReflectionProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/user/$userId/reflections-submitted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'data': []};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString(), 'data': []};
    }
  }

  // Record post/comment submission for belt progress tracking
  Future<Map<String, dynamic>> recordPostSubmission(
    String commentId,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forum/comments/$commentId/submitted'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'msg': 'Failed to record post'};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // Get user's post/comment submission history
  Future<Map<String, dynamic>> getUserPostProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forum/user/$userId/posts-submitted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'data': []};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString(), 'data': []};
    }
  }

  // Record share tip submission for belt progress tracking
  Future<Map<String, dynamic>> recordShareTipSubmission(
    String postId,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forum/posts/$postId/share-tip-submitted'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'msg': 'Failed to record share tip'};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // Get user's share tip submission history
  Future<Map<String, dynamic>> getUserShareTipProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forum/user/$userId/share-tips-submitted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'data': []};
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString(), 'data': []};
    }
  }
}
