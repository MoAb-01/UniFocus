class University {
  final String id;
  final String name;
  final String turkishName;
  final String shortName;
  final String city;
  final String type; // State, Foundation
  final String campus;
  final int establishedYear;
  final String website;
  final String description;
  final List<String> faculties;
  final List<String> departments;

  const University({
    required this.id,
    required this.name,
    required this.turkishName,
    required this.shortName,
    required this.city,
    required this.type,
    required this.campus,
    required this.establishedYear,
    required this.website,
    required this.description,
    required this.faculties,
    required this.departments,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'turkishName': turkishName,
    'shortName': shortName,
    'city': city,
    'type': type,
    'campus': campus,
    'establishedYear': establishedYear,
    'website': website,
    'description': description,
    'faculties': faculties,
    'departments': departments,
  };

  factory University.fromJson(Map<String, dynamic> json) => University(
    id: json['id'] as String,
    name: json['name'] as String,
    turkishName: json['turkishName'] as String,
    shortName: json['shortName'] as String,
    city: json['city'] as String,
    type: json['type'] as String,
    campus: json['campus'] as String,
    establishedYear: json['establishedYear'] as int,
    website: json['website'] as String,
    description: json['description'] as String,
    faculties: List<String>.from(json['faculties'] as List),
    departments: List<String>.from(json['departments'] as List),
  );
}
