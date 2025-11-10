import 'package:get/get.dart';
import '../models/sample_model.dart';
import '../../../http_client/api_client.dart';

class ApiRepository {
  ApiRepository(this._client);
  final ApiClient _client;

  Future<SampleModel> getSample() async 
  {
    final Response res = await _client.fetchSample();
    
    if (res.isOk && res.body != null) {
      return SampleModel.fromJson(res.body);
    } else {
      throw Exception('Failed to fetch sample: ${res.statusText}');
    }
  }

  Future<SampleModel> insertSample({
    required String title,
    required String content,
  }) async {
    final Response res = await _client.insertSample(
      title: title,
      content: content,
    );

    if (res.isOk && res.body != null) {
      return SampleModel.fromJson(res.body['data']);
    } else {
      throw Exception('Failed to insert sample: ${res.statusText}');
    }
  }
}
