import 'package:get/get.dart';
import '../http_client/api_client.dart';
import '../controller/home_controller/repository/api_repository.dart';
import '../controller/home_controller/controller/home_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient());
    Get.put(ApiRepository(Get.find<ApiClient>()));
    Get.put(HomeController(Get.find<ApiRepository>()));
  }
}