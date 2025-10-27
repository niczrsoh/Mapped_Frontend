import 'package:get/get.dart';
import '../../global/routes.dart';

class LoginController extends GetxController {
  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  void login() async {
    loading.value = true;
    error.value = '';
    await Future.delayed(const Duration(milliseconds: 600));
    loading.value = false;
    Get.offAllNamed(AppRoutes.home);
  }
}