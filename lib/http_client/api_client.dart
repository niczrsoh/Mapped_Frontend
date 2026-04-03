import 'package:get/get.dart';
import 'package:mapped_frontend/services/api_service.dart';

class ApiClient extends GetConnect {
  final ApiService _apiService = ApiService();
  @override
  void onInit() {
    httpClient.baseUrl = _apiService.baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    super.onInit();
  }

  Future<Response> fetchSample() => get('/sample');

  Future<Response> insertSample({
    required String title,
    required String content,
  }) {
    final body = {'title': title, 'content': content};
    return post('/sample/insert', body);
  }

  Future<Response> fetchAllSamples() => get('/sample/all');
}
