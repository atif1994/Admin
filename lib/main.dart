import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}
///ok  used
/// MVC + GetX: GetMaterialApp with routes and bindings.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.home,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
    );
  }
}
