import 'package:get/get.dart';
import '../repository/api_repository.dart';
import '../models/sample_model.dart';

class HomeController extends GetxController {
  HomeController(this._repo);
  final ApiRepository _repo;

  final Rx<SampleModel?> sample = Rx<SampleModel?>(null);
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  /// Load sample from API
  Future<void> load() async {
    loading.value = true;
    error.value = '';
    try {
      sample.value = await _repo.getSample();
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  /// ✅ Insert a new sample into the backend
  Future<void> insert({String? title, String? content}) async {
    loading.value = true;
    error.value = '';
    try {
      final insertedSample = await _repo.insertSample(
        title: title ?? 'Test Document',
        content: content ?? 'Inserted from Flutter!',
      );
      sample.value = insertedSample;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
