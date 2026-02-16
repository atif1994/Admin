import 'package:get/get.dart';

import '../bindings/home_binding.dart';
import '../screens/home_screen.dart';
import '../screens/create_record_screen.dart';

import 'app_routes.dart';

/// GetX route definitions (MVC: View layer entry points).
/// Login and signup screens removed — app opens directly to home.
class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.createRecord,
      page: () => const CreateRecordScreen(),
      binding: HomeBinding(),
    ),
  ];
}
