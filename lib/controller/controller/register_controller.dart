import 'package:get/get.dart';
import '../../global/routes.dart';

class RegisterController extends GetxController {
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString passwordConfirmation = ''.obs;

  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  bool get canSubmit {
    return fullName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password == passwordConfirmation;
  }

  Future<void> register() async {
    error.value = '';
    if (!canSubmit) {
      error.value = 'Please fill fields correctly.';
      return;
    }

    loading.value = true;
    try {
      // TODO: call API to register. For now simulate network delay.
      await Future.delayed(const Duration(milliseconds: 800));
      // On success, navigate to login (or home if preferred)
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
