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
/// Contains multiple doses.
class Vaccine {
  const Vaccine({
    required this.id,
    required this.name,
    this.brand,
    required this.doses,
  });

  final String id;
  final String name;
  final String? brand; // e.g. China, America
  final List<Dose> doses;

  Vaccine copyWith({
    String? id,
    String? name,
    String? brand,
    List<Dose>? doses,
  }) {
    return Vaccine(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      doses: doses ?? this.doses,
    );
  }
}

/// One dose within a vaccine (e.g. TB 1, TB 2, BCG 1, PA, PS).
class Dose {
  const Dose({
    required this.id,
    required this.name,
    this.administeredAt,
  });

  final String id;
  final String name;
  final DateTime? administeredAt;

  Dose copyWith({
    String? id,
    String? name,
    DateTime? administeredAt,
  }) {
    return Dose(
      id: id ?? this.id,
      name: name ?? this.name,
      administeredAt: administeredAt ?? this.administeredAt,
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
      ),
      Vaccine(
        id: 'v2',
        name: 'BCG',
        brand: 'America',
        doses: const [
          Dose(id: 'd3', name: 'BCG 1'),
        ],
      ),
      Vaccine(
        id: 'v3',
        name: 'PENTVALENT',
        brand: 'China',
        doses: const [
          Dose(id: 'd4', name: 'PA'),
          Dose(id: 'd5', name: 'PS'),
        ],
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
      ),
    ],
  );
}

List<VaccinationRecord> sampleRecords() => [sampleRecord1(), sampleRecord2()];
