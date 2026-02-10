import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/vaccination_record.dart';
import '../theme/app_theme.dart';
import '../controllers/records_controller.dart';

/// Create/Edit record: vaccines and doses only. Doses show when user expands a vaccine.
/// User can add/remove vaccines and add/remove doses. No Record (date/child/visit) section.
class CreateRecordScreen extends StatefulWidget {
  const CreateRecordScreen({super.key, this.existingRecord});

  final VaccinationRecord? existingRecord;

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
    
    // If editing, populate with existing data
    if (widget.existingRecord != null) {
      for (final vaccine in widget.existingRecord!.vaccines) {
        final entry = _VaccineEntry();
        entry.nameController.text = vaccine.name;
        entry.brandController.text = vaccine.brand ?? '';
        
        // Populate age configuration
        if (vaccine.minimumAgeValue != null) {
          entry.selectedMinimumAge = _formatAgeDisplay(
            vaccine.minimumAgeValue!,
            vaccine.minimumAgeUnit,
          );
        }
        
        if (vaccine.maximumAgeValue != null && !vaccine.isMaximumAgeInfinite) {
          entry.selectedMaximumAge = _formatAgeDisplay(
            vaccine.maximumAgeValue!,
            vaccine.maximumAgeUnit,
          );
        }
        
        entry.isMaximumAgeInfinite = vaccine.isMaximumAgeInfinite;
        entry.selectedMaximumGapYears = vaccine.maximumGapYears;
        
        // Populate doses (with per-dose min age and gap)
        for (final dose in vaccine.doses) {
          final doseEntry = _DoseEntry();
          doseEntry.nameController.text = dose.name;
          if (dose.minimumAgeValue != null) {
            doseEntry.selectedMinimumAge = _formatAgeDisplay(
              dose.minimumAgeValue!,
              dose.minimumAgeUnit,
            );
          }
          doseEntry.selectedMaximumGapYears = dose.maximumGapYears;
          entry.doseEntries.add(doseEntry);
        }
        
        _vaccines.add(entry);
      }
    } else {
      // Start with 1 empty vaccine with 1 dose field for new record
      final e = _VaccineEntry();
      e.doseEntries.add(_DoseEntry());
      _vaccines.add(e);
    }
  }
  
  /// Format age value and unit to display string (e.g., "6 Months")
  String _formatAgeDisplay(int value, AgeUnit unit) {
    final unitName = unit == AgeUnit.week
        ? 'Week'
        : unit == AgeUnit.month
            ? 'Month'
            : 'Year';
    return value == 1 ? '1 $unitName' : '$value ${unitName}s';
  }

  @override
  void dispose() {
    for (final v in _vaccines) {
      v.nameController.dispose();
      v.brandController.dispose();
      for (final d in v.doseEntries) {
        d.nameController.dispose();
      }
    }
    super.dispose();
  }

  void _addVaccine() {
    setState(() {
      final e = _VaccineEntry();
      e.doseEntries.add(_DoseEntry());
      _vaccines.add(e);
    });
  }

  void _removeVaccine(int index) {
    setState(() {
      for (final d in _vaccines[index].doseEntries) {
        d.nameController.dispose();
      }
      _vaccines.removeAt(index);
    });
  }

  void _addDose(int vaccineIndex) {
    setState(() {
      _vaccines[vaccineIndex].doseEntries.add(_DoseEntry());
    });
  }

  void _removeDose(int vaccineIndex, int doseIndex) {
    setState(() {
      _vaccines[vaccineIndex].doseEntries[doseIndex].nameController.dispose();
      _vaccines[vaccineIndex].doseEntries.removeAt(doseIndex);
    });
  }

  /// Parse age selection like "6 Months" to {value: 6, unit: AgeUnit.month}
  Map<String, dynamic>? _parseAgeSelection(String? selection) {
    if (selection == null || selection.isEmpty) return null;
    
    // Handle complex formats like "1 Year 6 Months"
    if (selection.contains('Year') && selection.split('Year').length > 1) {
      final parts = selection.split('Year');
      final yearValue = int.tryParse(parts[0].trim());
      if (yearValue != null) {
        // For now, return year value (could be enhanced to handle months too)
        return {'value': yearValue, 'unit': AgeUnit.year};
      }
    }
    
    // Handle simple formats: "6 Months", "1 Week", "3 Years"
    final parts = selection.trim().split(' ');
    if (parts.length >= 2) {
      final value = int.tryParse(parts[0]);
      final unitStr = parts[1].toLowerCase();
      
      AgeUnit? unit;
      if (unitStr.startsWith('week')) {
        unit = AgeUnit.week;
      } else if (unitStr.startsWith('month')) {
        unit = AgeUnit.month;
      } else if (unitStr.startsWith('year')) {
        unit = AgeUnit.year;
      }
      
      if (value != null && unit != null) {
        return {'value': value, 'unit': unit};
      }
    }
    
    return null;
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
      for (var j = 0; j < v.doseEntries.length; j++) {
        final de = v.doseEntries[j];
        final doseName = de.nameController.text.trim();
        if (doseName.isEmpty) continue;
        final doseMinAge = _parseAgeSelection(de.selectedMinimumAge);
        doses.add(Dose(
          id: _newId(),
          name: doseName,
          minimumAgeValue: doseMinAge?['value'],
          minimumAgeUnit: doseMinAge?['unit'] ?? AgeUnit.month,
          maximumGapYears: de.selectedMaximumGapYears,
        ));
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
      // Parse age configuration values from searchable dropdown selections
      final minAgeData = _parseAgeSelection(v.selectedMinimumAge);
      final maxAgeData = v.isMaximumAgeInfinite 
          ? null 
          : _parseAgeSelection(v.selectedMaximumAge);
      
      vaccines.add(Vaccine(
        id: _newId(),
        name: name,
        brand: v.brandController.text.trim().isEmpty
            ? null
            : v.brandController.text.trim(),
        doses: doses,
        minimumAgeValue: minAgeData?['value'],
        minimumAgeUnit: minAgeData?['unit'] ?? AgeUnit.month,
        maximumAgeValue: maxAgeData?['value'],
        maximumAgeUnit: maxAgeData?['unit'] ?? AgeUnit.year,
        isMaximumAgeInfinite: v.isMaximumAgeInfinite,
        maximumGapYears: v.selectedMaximumGapYears,
      ));
    }

    if (widget.existingRecord != null) {
      // Update existing record
      final updatedRecord = widget.existingRecord!.copyWith(
        vaccines: vaccines,
      );
      Get.find<RecordsController>().updateRecord(updatedRecord);
    } else {
      // Create new record
      final record = VaccinationRecord(
        id: _newId(),
        date: DateTime.now(),
        childName: 'Child',
        visit: 'Visit 1',
        vaccines: vaccines,
      );
      Get.find<RecordsController>().addRecord(record);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit record' : 'New record'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Per-dose entry: name + minimum age + gap between doses
class _DoseEntry {
  _DoseEntry();

  final nameController = TextEditingController();
  String? selectedMinimumAge;   // e.g., "6 Months"
  int? selectedMaximumGapYears; // e.g., 1, 2, 3 years
}

class _VaccineEntry {
  _VaccineEntry();

  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final List<_DoseEntry> doseEntries = [];
  
  // Vaccine-level age configuration (searchable)
  String? selectedMinimumAge;
  String? selectedMaximumAge;
  bool isMaximumAgeInfinite = false;
  int? selectedMaximumGapYears;
}

class _VaccineFormCard extends StatefulWidget {
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
  State<_VaccineFormCard> createState() => _VaccineFormCardState();
}

class _VaccineFormCardState extends State<_VaccineFormCard> {
  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final index = widget.index;
    final doseCount = entry.doseEntries.length;
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
                      onPressed: widget.onRemove,
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
                  onChanged: (_) => widget.onNameChanged(),
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
                const SizedBox(height: 20),
                
                // Age Configuration Section
                Divider(color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text(
                  'Age Configuration',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                
                // Minimum Age
                Text(
                  'Minimum Age',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return Vaccine.generateAgeOptions();
                    }
                    return Vaccine.generateAgeOptions().where((option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (selection) {
                    setState(() {
                      entry.selectedMinimumAge = selection;
                    });
                  },
                  initialValue: entry.selectedMinimumAge != null
                      ? TextEditingValue(text: entry.selectedMinimumAge!)
                      : null,
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search age (e.g., 1 Week, 6 Months)',
                        isDense: true,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onFieldSubmitted: (value) => onSubmit(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Maximum Age
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Maximum Age',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: entry.isMaximumAgeInfinite,
                          onChanged: (value) {
                            setState(() {
                              entry.isMaximumAgeInfinite = value ?? false;
                              if (entry.isMaximumAgeInfinite) {
                                entry.selectedMaximumAge = null;
                              }
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text(
                          'Infinite',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (entry.isMaximumAgeInfinite) return const Iterable<String>.empty();
                    if (textEditingValue.text.isEmpty) {
                      return Vaccine.generateAgeOptions();
                    }
                    return Vaccine.generateAgeOptions().where((option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (selection) {
                    setState(() {
                      entry.selectedMaximumAge = selection;
                    });
                  },
                  initialValue: entry.selectedMaximumAge != null
                      ? TextEditingValue(text: entry.selectedMaximumAge!)
                      : null,
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search age (e.g., 5 Years)',
                        isDense: true,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      enabled: !entry.isMaximumAgeInfinite,
                      onFieldSubmitted: (value) => onSubmit(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Maximum Gap Between Doses
                Text(
                  'Maximum Gap Between Doses',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: entry.selectedMaximumGapYears,
                  decoration: const InputDecoration(
                    hintText: 'Select maximum gap',
                    helperText: 'The maximum allowable gap between doses in years',
                    helperMaxLines: 2,
                    isDense: true,
                  ),
                  items: List.generate(10, (index) {
                    final year = index + 1;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year == 1 ? '1 Year' : '$year Years'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      entry.selectedMaximumGapYears = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Divider(color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doses',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      onPressed: widget.onAddDose,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primary,
                      tooltip: 'Add dose',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(entry.doseEntries.length, (j) {
                    final doseEntry = entry.doseEntries[j];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: doseEntry.nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Dose ${j + 1}',
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
                                  onPressed: () => widget.onRemoveDose(j),
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Minimum age (this dose)',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Autocomplete<String>(
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return Vaccine.generateAgeOptions();
                                }
                                return Vaccine.generateAgeOptions().where((option) {
                                  return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                                });
                              },
                              onSelected: (selection) {
                                setState(() {
                                  doseEntry.selectedMinimumAge = selection;
                                });
                              },
                              initialValue: doseEntry.selectedMinimumAge != null
                                  ? TextEditingValue(text: doseEntry.selectedMinimumAge!)
                                  : null,
                              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g., 6 Months',
                                    isDense: true,
                                    suffixIcon: Icon(Icons.arrow_drop_down, size: 24),
                                  ),
                                  onFieldSubmitted: (value) => onSubmit(),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gap from previous dose (years)',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: doseEntry.selectedMaximumGapYears,
                              decoration: const InputDecoration(
                                hintText: 'Select gap',
                                isDense: true,
                              ),
                              items: List.generate(10, (index) {
                                final year = index + 1;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year == 1 ? '1 Year' : '$year Years'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  doseEntry.selectedMaximumGapYears = value;
                                });
                              },
                            ),
                          ],
                        ),
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
