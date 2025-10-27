import 'package:get/get.dart';
import '../helper/constants.dart';

class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    super.onInit();
  }

  Future<Response> fetchSample() => get('/sample');
}