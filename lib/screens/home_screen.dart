import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';
import '../controllers/records_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import 'create_record_screen.dart';

/// MVC View: list of records (date / child / visit).
/// Uses [RecordsController] for data and [AuthController] for logout.
/// Tap a record to select it and show edit/delete bottom bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final DateFormat _dateFormat = DateFormat('MMM d, y');

  RecordsController get _records => Get.find<RecordsController>();
  AuthController get _auth => Get.find<AuthController>();

  void _showOptionsBottomSheet(VaccinationRecord record) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppTheme.primary),
              title: const Text('Edit'),
              onTap: () {
                Get.back();
                _editRecord(record);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.error),
              title: Text('Delete', style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Get.back();
                _deleteRecord(record);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _editRecord(VaccinationRecord record) {
    Get.to(
      () => CreateRecordScreen(existingRecord: record),
      transition: Transition.rightToLeft,
    );
  }

  void _deleteRecord(VaccinationRecord record) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _records.removeRecord(record.id);
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _auth.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createRecord),
        tooltip: 'Create record',
        backgroundColor: AppTheme.primaryLight,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_records.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final list = _records.records;
        if (list.isEmpty) {
          return _buildEmpty();
        }
        return RefreshIndicator(
          onRefresh: _records.loadRecords,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final record = list[index];
              return _RecordCard(
                record: record,
                dateFormat: _dateFormat,
                onMenuTap: () => _showOptionsBottomSheet(record),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No vaccination records yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.dateFormat,
    required this.onMenuTap,
  });

  final VaccinationRecord record;
  final DateFormat dateFormat;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    // Show vaccine names as title
    final vaccineNames = record.vaccines.map((v) => v.name).where((n) => n.isNotEmpty).toList();
    final title = vaccineNames.isEmpty 
        ? 'Vaccination Record' 
        : vaccineNames.length == 1
            ? vaccineNames.first
            : '${vaccineNames.first} + ${vaccineNames.length - 1} more';
    
    // Count total doses
    final totalDoses = record.vaccines.fold<int>(
      0, 
      (sum, vaccine) => sum + vaccine.doses.length,
    );
    
    // If only one vaccine, show doses directly without vaccine tile wrapper
    final hasOnlyOneVaccine = record.vaccines.length == 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surfaceCard,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.vaccines_outlined,
              color: AppTheme.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                onPressed: onMenuTap,
                tooltip: 'Options',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          subtitle: Text(
            '${dateFormat.format(record.date)} · $totalDoses dose${totalDoses == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          children: hasOnlyOneVaccine
              ? [
                  // Show brand if available
                  if (record.vaccines.first.brand != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.vaccines_outlined,
                            color: AppTheme.primaryLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.vaccines.first.brand!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  // Show doses directly
                  ...record.vaccines.first.doses
                      .map((dose) => _DoseTile(dose: dose))
                      .toList(),
                ]
              : record.vaccines
                  .map((vaccine) => _VaccineTile(vaccine: vaccine))
                  .toList(),
        ),
      ),
    );
  }
}

class _VaccineTile extends StatelessWidget {
  const _VaccineTile({required this.vaccine});

  final Vaccine vaccine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Card(
        color: AppTheme.surface,
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(
            Icons.vaccines_outlined,
            color: AppTheme.primaryLight,
            size: 28,
          ),
          title: Text(
            vaccine.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: vaccine.brand != null
              ? Text(
                  vaccine.brand!,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : null,
          children: vaccine.doses
              .map((dose) => _DoseTile(dose: dose))
              .toList(),
        ),
      ),
    );
  }
}

class _DoseTile extends StatelessWidget {
  const _DoseTile({required this.dose});

  final Dose dose;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.medication_outlined,
        size: 22,
        color: AppTheme.onSurfaceVariant,
      ),
      title: Text(
        dose.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: dose.administeredAt != null
          ? Text(
              DateFormat('MMM d, y').format(dose.administeredAt!),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}
