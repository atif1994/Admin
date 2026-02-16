import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// MVC Controller: authentication state and actions (login, signup, logout).
class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
  }

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email and password',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
      return;
    }

    // DEV MODE: Skip login if credentials are "admin@test.com" / "admin123"
    if (email.trim() == 'admin@test.com' && password == 'admin123') {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      isLoading.value = false;
      
      Get.offAllNamed(Routes.home);
      Get.snackbar(
        'Success',
        'Login successful (Dev Mode)',
        backgroundColor: AppTheme.success,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.login(
        email: email.trim(),
        password: password,
      );

      if (response['success'] == true) {
        Get.offAllNamed(Routes.home);
        Get.snackbar(
          'Success',
          response['message'] ?? 'Login successful',
          backgroundColor: AppTheme.success,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Login failed',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: AppTheme.error,
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
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.signup(
        fullName: name.trim(),
        email: email.trim(),
        password: password,
      );

      if (response['success'] == true) {
        // After successful signup, go to home
        Get.offAllNamed(Routes.home);
        Get.snackbar(
          'Success',
          response['message'] ?? 'Account created successfully',
          backgroundColor: AppTheme.success,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Signup failed',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    // Admin app no longer has login - just clear token
    Get.snackbar(
      'Logged Out',
      'Token cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
