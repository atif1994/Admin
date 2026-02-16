import 'package:get/get.dart';

/// Registers app-wide controllers that must survive route changes.
/// Login/signup removed — no AuthController needed.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // No global controllers; HomeBinding provides RecordsController
  }
}
