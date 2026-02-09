/// Standard vaccines with typical number of doses (for display and pre-fill).
class StandardVaccine {
  const StandardVaccine({
    required this.name,
    required this.typicalDoses,
  });

  final String name;
  final String typicalDoses;
}

const List<StandardVaccine> standardVaccines = [
  StandardVaccine(name: 'BCG', typicalDoses: '1 dose'),
  StandardVaccine(name: 'Hepatitis B', typicalDoses: '3 doses'),
  StandardVaccine(
    name: 'DPT / Pentavalent (Diptheria, Pertussis, Tetanus + Hib + Hep B)',
    typicalDoses: '3–4 doses',
  ),
  StandardVaccine(name: 'OPV (Polio)', typicalDoses: '4 doses'),
  StandardVaccine(name: 'IPV (Inactivated Polio)', typicalDoses: '2–4 doses'),
  StandardVaccine(name: 'MMR', typicalDoses: '2 doses'),
  StandardVaccine(name: 'Varicella (Chickenpox)', typicalDoses: '2 doses'),
  StandardVaccine(name: 'Hepatitis A', typicalDoses: '2 doses'),
  StandardVaccine(name: 'PCV (Pneumococcal)', typicalDoses: '3–4 doses'),
  StandardVaccine(name: 'Rotavirus', typicalDoses: '2–3 doses'),
  StandardVaccine(name: 'Measles', typicalDoses: '2 doses (usually part of MMR)'),
  StandardVaccine(name: 'Meningococcal', typicalDoses: '1–2 doses (age dependent)'),
  StandardVaccine(name: 'HPV (Human Papillomavirus)', typicalDoses: '2–3 doses (older kids)'),
  StandardVaccine(name: 'Influenza (Flu)', typicalDoses: 'Yearly (1 dose per year)'),
];
