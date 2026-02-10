import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';

/// MVC Controller: vaccination records list and actions.
class RecordsController extends GetxController {
  final RxList<VaccinationRecord> records = <VaccinationRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    records.addAll(sampleRecords());
  }

  void addRecord(VaccinationRecord record) {
    records.insert(0, record);
    Get.snackbar(
      'Created',
      'Record created',
      backgroundColor: AppTheme.success,
      colorText: AppTheme.onPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    );
  }

  void updateRecord(VaccinationRecord updatedRecord) {
    final index = records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      Get.snackbar(
        'Updated',
        'Record updated successfully',
        backgroundColor: AppTheme.success,
        colorText: AppTheme.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      );
    }
  }

  void removeRecord(String id) {
    records.removeWhere((r) => r.id == id);
  }
}
