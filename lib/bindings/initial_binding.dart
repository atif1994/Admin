import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Registers app-wide controllers that must survive route changes.
/// [AuthController] is permanent so logout works from [HomeScreen].
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
