import 'package:get/get.dart';

/// GetX binding for login/signup views.
/// [AuthController] is registered in [InitialBinding] (permanent) so it
/// remains available after navigating to home.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController is put in InitialBinding with permanent: true
  }
}
