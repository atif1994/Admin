import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';
import '../controllers/records_controller.dart';

/// Create record: vaccines and doses only. Doses show when user expands a vaccine.
/// User can add/remove vaccines and add/remove doses. No Record (date/child/visit) section.
class CreateRecordScreen extends StatefulWidget {
  const CreateRecordScreen({super.key});

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_VaccineEntry> _vaccines = [];

  static String _newId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    // Start with 1 empty vaccine with 2 dose fields
    final e = _VaccineEntry();
    e.doseControllers.add(TextEditingController());
    e.doseControllers.add(TextEditingController());
    _vaccines.add(e);
  }

  @override
  void dispose() {
    for (final v in _vaccines) {
      for (final c in v.doseControllers) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addVaccine() {
    setState(() {
      final e = _VaccineEntry(); // extra/custom vaccine, no typical doses
      // Pre-add 2 dose fields
      e.doseControllers.add(TextEditingController());
      e.doseControllers.add(TextEditingController());
      _vaccines.add(e);
    });
  }

  void _removeVaccine(int index) {
    setState(() {
      for (final c in _vaccines[index].doseControllers) {
        c.dispose();
      }
      _vaccines.removeAt(index);
    });
  }

  void _addDose(int vaccineIndex) {
    setState(() {
      _vaccines[vaccineIndex].doseControllers.add(TextEditingController());
    });
  }

  void _removeDose(int vaccineIndex, int doseIndex) {
    setState(() {
      _vaccines[vaccineIndex].doseControllers[doseIndex].dispose();
      _vaccines[vaccineIndex].doseControllers.removeAt(doseIndex);
    });
  }

  void _save() {
    if (_vaccines.isEmpty) {
      Get.snackbar(
        'Required',
        'Add at least one vaccine with doses',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final vaccines = <Vaccine>[];
    for (var i = 0; i < _vaccines.length; i++) {
      final v = _vaccines[i];
      final name = v.nameController.text.trim();
      if (name.isEmpty) {
        Get.snackbar(
          'Required',
          'Vaccine ${i + 1}: please enter name',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      final doses = <Dose>[];
      for (var j = 0; j < v.doseControllers.length; j++) {
        final doseName = v.doseControllers[j].text.trim();
        if (doseName.isEmpty) continue;
        doses.add(Dose(id: _newId(), name: doseName));
      }
      if (doses.isEmpty) {
        Get.snackbar(
          'Required',
          'Vaccine "$name": add at least one dose (tap vaccine to show doses)',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      vaccines.add(Vaccine(
        id: _newId(),
        name: name,
        brand: v.brandController.text.trim().isEmpty
            ? null
            : v.brandController.text.trim(),
        doses: doses,
      ));
    }

    final record = VaccinationRecord(
      id: _newId(),
      date: DateTime.now(),
      childName: 'Child',
      visit: 'Visit 1',
      vaccines: vaccines,
    );
    Get.find<RecordsController>().addRecord(record);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New record'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vaccines & doses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                FilledButton.icon(
                  onPressed: _addVaccine,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add vaccine'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_vaccines.length, (i) {
              return _VaccineFormCard(
                index: i,
                entry: _vaccines[i],
                onRemove: () => _removeVaccine(i),
                onAddDose: () => _addDose(i),
                onRemoveDose: (doseIndex) => _removeDose(i, doseIndex),
                onNameChanged: () => setState(() {}),
              );
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addVaccine,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add extra vaccine'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VaccineEntry {
  _VaccineEntry();

  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final List<TextEditingController> doseControllers = [];
}

class _VaccineFormCard extends StatelessWidget {
  const _VaccineFormCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onAddDose,
    required this.onRemoveDose,
    required this.onNameChanged,
  });

  final int index;
  final _VaccineEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onAddDose;
  final void Function(int doseIndex) onRemoveDose;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    final doseCount = entry.doseControllers.length;
    final vaccineName = entry.nameController.text.trim().isEmpty
        ? 'Vaccine ${index + 1}'
        : entry.nameController.text.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.vaccines_outlined, color: AppTheme.primaryLight),
        title: Text(
          vaccineName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: doseCount > 0
            ? Text(
                '$doseCount dose${doseCount == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Remove vaccine'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: entry.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccine',
                    hintText: 'Select vaccine',
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: entry.brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand (optional)',
                    hintText: 'e.g. China, America',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doses',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    IconButton(
                      onPressed: onAddDose,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primary,
                      tooltip: 'Add dose',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(entry.doseControllers.length, (j) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.doseControllers[j],
                              decoration: InputDecoration(
                                hintText: j == 0 ? 'Select dose' : 'Dose ${j + 1}',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => onRemoveDose(j),
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
