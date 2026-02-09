import 'package:get/get.dart';

import '../controllers/records_controller.dart';

/// GetX binding: injects [RecordsController] for home and create-record views.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordsController>(() => RecordsController());
  }
}
