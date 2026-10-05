enum ProgramType {
  main,
  cap, // Double Major
  minor, // Yandal
}

class Program {
  final String id;
  final String name;
  final String department;
  final ProgramType type;
  final double gano;
  final int completedAkts;

  const Program({
    required this.id,
    required this.name,
    required this.department,
    required this.type,
    this.gano = 0.0,
    this.completedAkts = 0,
  });

  String get typeLabel {
    switch (type) {
      case ProgramType.main:
        return 'Main Program';
      case ProgramType.cap:
        return 'Double Major (ÇAP)';
      case ProgramType.minor:
        return 'Minor (Yandal)';
    }
  }

  Program copyWith({
    String? id,
    String? name,
    String? department,
    ProgramType? type,
    double? gano,
    int? completedAkts,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      type: type ?? this.type,
      gano: gano ?? this.gano,
      completedAkts: completedAkts ?? this.completedAkts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'department': department,
    'type': type.name,
    'gano': gano,
    'completedAkts': completedAkts,
  };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'] as String,
    name: json['name'] as String,
    department: json['department'] as String,
    type: ProgramType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ProgramType.main,
    ),
    gano: (json['gano'] as num?)?.toDouble() ?? 0.0,
    completedAkts: json['completedAkts'] as int? ?? 0,
  );
}
