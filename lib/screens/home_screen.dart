import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';
import '../controllers/records_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

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
  String? _selectedRecordId;

  RecordsController get _records => Get.find<RecordsController>();
  AuthController get _auth => Get.find<AuthController>();

  void _selectRecord(String? id) {
    setState(() {
      _selectedRecordId = id;
    });
  }

  void _editRecord() {
    if (_selectedRecordId == null) return;
    // TODO: Navigate to edit screen with record data
    Get.snackbar(
      'Edit',
      'Edit functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    _selectRecord(null);
  }

  void _deleteRecord() {
    if (_selectedRecordId == null) return;
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
              _records.removeRecord(_selectedRecordId!);
              Get.back();
              _selectRecord(null);
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
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.createRecord),
            tooltip: 'Create record',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _auth.logout,
          ),
        ],
      ),
      floatingActionButton: _selectedRecordId == null
          ? FloatingActionButton(
              onPressed: () => Get.toNamed(Routes.createRecord),
              tooltip: 'Create record',
              backgroundColor: AppTheme.primaryLight,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _selectedRecordId != null
          ? BottomAppBar(
              color: AppTheme.surfaceCard,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editRecord,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _deleteRecord,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Obx(() {
        final list = _records.records;
        if (list.isEmpty) {
          return _buildEmpty();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final record = list[index];
            return _RecordCard(
              record: record,
              dateFormat: _dateFormat,
              isSelected: _selectedRecordId == record.id,
              onTap: () {
                _selectRecord(
                  _selectedRecordId == record.id ? null : record.id,
                );
              },
            );
          },
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
    required this.isSelected,
    required this.onTap,
  });

  final VaccinationRecord record;
  final DateFormat dateFormat;
  final bool isSelected;
  final VoidCallback onTap;

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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected
          ? AppTheme.primary.withValues(alpha: 0.08)
          : AppTheme.surfaceCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.vaccines_outlined,
              color: isSelected ? AppTheme.onPrimary : AppTheme.primary,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryDark : null,
                ),
          ),
          subtitle: Text(
            '${dateFormat.format(record.date)} · $totalDoses dose${totalDoses == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          children: record.vaccines
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
