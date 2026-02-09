import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

/// MVC Controller: authentication state and actions (login, signup, logout).
class AuthController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return;
    isLoading.value = true;
    try {
      // TODO: Call auth API
      await Future<void>.delayed(const Duration(milliseconds: 400));
      Get.offAllNamed(Routes.home);
      Get.snackbar(
        'Success',
        'Login successful',
        backgroundColor: AppTheme.success,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return;
    }
    isLoading.value = true;
    try {
      // TODO: Call auth API
      await Future<void>.delayed(const Duration(milliseconds: 400));
      Get.back();
      Get.snackbar(
        'Success',
        'Account created successfully',
        backgroundColor: AppTheme.success,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.offAllNamed(Routes.login);
  }
}
