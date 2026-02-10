/// Age unit enum for vaccine age configurations
enum AgeUnit {
  week,
  month,
  year;

  String get displayName {
    switch (this) {
      case AgeUnit.week:
        return 'Week';
      case AgeUnit.month:
        return 'Month';
      case AgeUnit.year:
        return 'Year';
    }
  }
}

/// One vaccination record: date / child / visit.
/// Contains multiple vaccines, each with multiple doses.
class VaccinationRecord {
  const VaccinationRecord({
    required this.id,
    required this.date,
    required this.childName,
    required this.visit,
    required this.vaccines,
  });

  final String id;
  final DateTime date;
  final String childName;
  final String visit;
  final List<Vaccine> vaccines;

  VaccinationRecord copyWith({
    String? id,
    DateTime? date,
    String? childName,
    String? visit,
    List<Vaccine>? vaccines,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      childName: childName ?? this.childName,
      visit: visit ?? this.visit,
      vaccines: vaccines ?? this.vaccines,
    );
  }
}

/// One vaccine (e.g. TB, BCG, PENTVALENT) with optional brand.
/// Contains multiple doses and age configuration rules.
class Vaccine {
  const Vaccine({
    required this.id,
    required this.name,
    this.brand,
    required this.doses,
    this.minimumAgeValue,
    this.minimumAgeUnit = AgeUnit.month,
    this.maximumAgeValue,
    this.maximumAgeUnit = AgeUnit.year,
    this.isMaximumAgeInfinite = false,
    this.maximumGapYears,
  });

  final String id;
  final String name;
  final String? brand; // e.g. China, America
  final List<Dose> doses;

  // Age Configuration Section
  /// Minimum age value (e.g., 2 for "2 weeks")
  final int? minimumAgeValue;
  
  /// Minimum age unit (Week, Month, Year)
  final AgeUnit minimumAgeUnit;
  
  /// Maximum age value (e.g., 5 for "5 years")
  /// Ignored if isMaximumAgeInfinite is true
  final int? maximumAgeValue;
  
  /// Maximum age unit (Week, Month, Year)
  final AgeUnit maximumAgeUnit;
  
  /// If true, maximum age is infinite (no upper limit)
  final bool isMaximumAgeInfinite;
  
  /// Maximum gap between doses (in years)
  /// The maximum allowable gap between doses must be specified in years.
  final int? maximumGapYears;

  Vaccine copyWith({
    String? id,
    String? name,
    String? brand,
    List<Dose>? doses,
    int? minimumAgeValue,
    AgeUnit? minimumAgeUnit,
    int? maximumAgeValue,
    AgeUnit? maximumAgeUnit,
    bool? isMaximumAgeInfinite,
    int? maximumGapYears,
  }) {
    return Vaccine(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      doses: doses ?? this.doses,
      minimumAgeValue: minimumAgeValue ?? this.minimumAgeValue,
      minimumAgeUnit: minimumAgeUnit ?? this.minimumAgeUnit,
      maximumAgeValue: maximumAgeValue ?? this.maximumAgeValue,
      maximumAgeUnit: maximumAgeUnit ?? this.maximumAgeUnit,
      isMaximumAgeInfinite: isMaximumAgeInfinite ?? this.isMaximumAgeInfinite,
      maximumGapYears: maximumGapYears ?? this.maximumGapYears,
    );
  }

  /// Generate age selection dropdown options for searchable field
  /// Returns list in format: ["1 Week", "2 Weeks", ..., "1 Month", ..., "1 Year 1 Month", ...]
  static List<String> generateAgeOptions({int maxYears = 5}) {
    final List<String> options = [];

    // Add weeks (1-3)
    for (int i = 1; i <= 3; i++) {
      options.add(i == 1 ? '1 Week' : '$i Weeks');
    }

    // Add months (1-11)
    for (int i = 1; i <= 11; i++) {
      options.add(i == 1 ? '1 Month' : '$i Months');
    }

    // Add years with months combinations
    for (int year = 1; year <= maxYears; year++) {
      // Add year only
      options.add(year == 1 ? '1 Year' : '$year Years');

      // Add year + months (only if not the last year to keep list manageable)
      if (year < maxYears) {
        for (int month = 1; month <= 11; month++) {
          final yearText = year == 1 ? '1 Year' : '$year Years';
          final monthText = month == 1 ? '1 Month' : '$month Months';
          options.add('$yearText $monthText');
        }
      }
    }

    return options;
  }

  /// Validates age configuration rules
  String? validateAgeConfiguration() {
    // Check if minimum age is provided
    if (minimumAgeValue == null || minimumAgeValue! <= 0) {
      return 'Minimum age must be a positive value';
    }

    // Check maximum age if not infinite
    if (!isMaximumAgeInfinite) {
      if (maximumAgeValue == null || maximumAgeValue! <= 0) {
        return 'Maximum age must be a positive value or set to Infinite';
      }

      // Convert both to months for comparison
      final minInMonths = _convertToMonths(minimumAgeValue!, minimumAgeUnit);
      final maxInMonths = _convertToMonths(maximumAgeValue!, maximumAgeUnit);

      if (minInMonths > maxInMonths) {
        return 'Minimum age must be less than or equal to Maximum age';
      }
    }

    // Check maximum gap
    if (maximumGapYears != null && maximumGapYears! <= 0) {
      return 'Maximum gap must be a positive value';
    }

    return null; // Validation passed
  }

  /// Helper to convert age to months for comparison
  int _convertToMonths(int value, AgeUnit unit) {
    switch (unit) {
      case AgeUnit.week:
        return (value * 7 / 30).round(); // Approximate weeks to months
      case AgeUnit.month:
        return value;
      case AgeUnit.year:
        return value * 12;
    }
  }
}

/// One dose within a vaccine (e.g. TB 1, TB 2, BCG 1, PA, PS).
/// Can have per-dose minimum age and maximum gap from previous dose.
class Dose {
  const Dose({
    required this.id,
    required this.name,
    this.administeredAt,
    this.minimumAgeValue,
    this.minimumAgeUnit = AgeUnit.month,
    this.maximumGapYears,
  });

  final String id;
  final String name;
  final DateTime? administeredAt;

  /// Minimum age for this dose (e.g. 6 months for dose 1)
  final int? minimumAgeValue;
  final AgeUnit minimumAgeUnit;

  /// Maximum gap from previous dose in years (for dose 2, 3, etc.)
  final int? maximumGapYears;

  Dose copyWith({
    String? id,
    String? name,
    DateTime? administeredAt,
    int? minimumAgeValue,
    AgeUnit? minimumAgeUnit,
    int? maximumGapYears,
  }) {
    return Dose(
      id: id ?? this.id,
      name: name ?? this.name,
      administeredAt: administeredAt ?? this.administeredAt,
      minimumAgeValue: minimumAgeValue ?? this.minimumAgeValue,
      minimumAgeUnit: minimumAgeUnit ?? this.minimumAgeUnit,
      maximumGapYears: maximumGapYears ?? this.maximumGapYears,
    );
  }
}

/// Sample data matching the sketch: Brand → Vaccine → Dose.
VaccinationRecord sampleRecord1() {
  return VaccinationRecord(
    id: '1',
    date: DateTime.now().subtract(const Duration(days: 2)),
    childName: 'Child A',
    visit: 'Visit 1',
    vaccines: [
      Vaccine(
        id: 'v1',
        name: 'TB',
        brand: 'China',
        doses: const [
          Dose(id: 'd1', name: 'TB 1'),
          Dose(id: 'd2', name: 'TB 2'),
        ],
        minimumAgeValue: 6,
        minimumAgeUnit: AgeUnit.month,
        maximumAgeValue: 3,
        maximumAgeUnit: AgeUnit.year,
        isMaximumAgeInfinite: false,
        maximumGapYears: 1,
      ),
      Vaccine(
        id: 'v2',
        name: 'BCG',
        brand: 'America',
        doses: const [
          Dose(id: 'd3', name: 'BCG 1'),
        ],
        minimumAgeValue: 1,
        minimumAgeUnit: AgeUnit.week,
        maximumAgeValue: null,
        maximumAgeUnit: AgeUnit.year,
        isMaximumAgeInfinite: true, // No upper age limit
        maximumGapYears: null,
      ),
      Vaccine(
        id: 'v3',
        name: 'PENTVALENT',
        brand: 'China',
        doses: const [
          Dose(id: 'd4', name: 'PA'),
          Dose(id: 'd5', name: 'PS'),
        ],
        minimumAgeValue: 2,
        minimumAgeUnit: AgeUnit.month,
        maximumAgeValue: 2,
        maximumAgeUnit: AgeUnit.year,
        isMaximumAgeInfinite: false,
        maximumGapYears: 2,
      ),
    ],
  );
}

VaccinationRecord sampleRecord2() {
  return VaccinationRecord(
    id: '2',
    date: DateTime.now().subtract(const Duration(days: 5)),
    childName: 'Child B',
    visit: 'Visit 2',
    vaccines: [
      Vaccine(
        id: 'v4',
        name: 'BCG',
        brand: 'America',
        doses: const [
          Dose(id: 'd6', name: 'BCG 1'),
        ],
        minimumAgeValue: 1,
        minimumAgeUnit: AgeUnit.week,
        maximumAgeValue: null,
        maximumAgeUnit: AgeUnit.year,
        isMaximumAgeInfinite: true,
        maximumGapYears: null,
      ),
      Vaccine(
        id: 'v5',
        name: 'PENTVALENT',
        brand: 'America',
        doses: const [
          Dose(id: 'd7', name: 'PA'),
          Dose(id: 'd8', name: 'PS'),
          Dose(id: 'd9', name: 'PENTVALENT 3'),
        ],
        minimumAgeValue: 3,
        minimumAgeUnit: AgeUnit.month,
        maximumAgeValue: 5,
        maximumAgeUnit: AgeUnit.year,
        isMaximumAgeInfinite: false,
        maximumGapYears: 3,
      ),
    ],
  );
}

List<VaccinationRecord> sampleRecords() => [sampleRecord1(), sampleRecord2()];
