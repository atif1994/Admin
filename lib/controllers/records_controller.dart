import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/vaccination_record.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// MVC Controller: vaccination records list and actions.
class RecordsController extends GetxController {
  final RxList<VaccinationRecord> records = <VaccinationRecord>[].obs;
  final RxBool isLoading = false.obs;
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  /// Load all records from API
  Future<void> loadRecords() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getVaccinationRecords();

      if (response['success'] == true) {
        final recordsList = response['data']['records'] as List;
        records.value = recordsList
            .map((json) => VaccinationRecord.fromJson(json))
            .toList();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load records',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load records: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new record via API
  Future<void> addRecord(VaccinationRecord record) async {
    try {
      final response = await _apiService.createVaccinationRecord(
        record.toJson(),
      );

      if (response['success'] == true) {
        // Reload records to get the latest from server
        await loadRecords();
        Get.snackbar(
          'Created',
          'Record created successfully',
          backgroundColor: AppTheme.success,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to create record',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create record: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    }
  }

  /// Update existing record via API
  Future<void> updateRecord(VaccinationRecord updatedRecord) async {
    try {
      final response = await _apiService.updateVaccinationRecord(
        updatedRecord.id,
        updatedRecord.toJson(),
      );

      if (response['success'] == true) {
        // Update local list
        final index = records.indexWhere((r) => r.id == updatedRecord.id);
        if (index != -1) {
          records[index] = updatedRecord;
        }
        Get.snackbar(
          'Updated',
          'Record updated successfully',
          backgroundColor: AppTheme.success,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to update record',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update record: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    }
  }

  /// Delete record via API
  Future<void> removeRecord(String id) async {
    try {
      final response = await _apiService.deleteVaccinationRecord(id);

      if (response['success'] == true) {
        records.removeWhere((r) => r.id == id);
        Get.snackbar(
          'Deleted',
          'Record deleted successfully',
          backgroundColor: AppTheme.success,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to delete record',
          backgroundColor: AppTheme.error,
          colorText: AppTheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete record: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    }
  }

  /// Search records
  Future<void> searchRecords(String query) async {
    if (query.trim().isEmpty) {
      loadRecords();
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.searchRecords(query);

      if (response['success'] == true) {
        final recordsList = response['data']['records'] as List;
        records.value = recordsList
            .map((json) => VaccinationRecord.fromJson(json))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Search failed: ${e.toString()}',
        backgroundColor: AppTheme.error,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
