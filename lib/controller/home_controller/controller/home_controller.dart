import 'package:get/get.dart';
import '../repository/api_repository.dart';
import '../models/sample_model.dart';

class HomeController extends GetxController {
  HomeController(this._repo);
  final ApiRepository _repo;

  final Rx<SampleModel?> sample = Rx<SampleModel?>(null);
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

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
}