class StudyPlace {
  final String id;
  final String name;
  final String city;
  final String campusOrDistrict;
  final String type; // 'University Library', 'Public Library', 'Study Hall', 'Cafe'
  final String address;
  final String openingHours;
  final String crowdLevel; // 'quiet', 'moderate', 'crowded'
  final bool hasWifi;
  final bool hasOutlets;
  final bool isSilentZone;
  final double rating;

  const StudyPlace({
    required this.id,
    required this.name,
    required this.city,
    required this.campusOrDistrict,
    required this.type,
    required this.address,
    required this.openingHours,
    required this.crowdLevel,
    required this.hasWifi,
    required this.hasOutlets,
    required this.isSilentZone,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'campusOrDistrict': campusOrDistrict,
    'type': type,
    'address': address,
    'openingHours': openingHours,
    'crowdLevel': crowdLevel,
    'hasWifi': hasWifi,
    'hasOutlets': hasOutlets,
    'isSilentZone': isSilentZone,
    'rating': rating,
  };

  factory StudyPlace.fromJson(Map<String, dynamic> json) => StudyPlace(
    id: json['id'] as String,
    name: json['name'] as String,
    city: json['city'] as String,
    campusOrDistrict: json['campusOrDistrict'] as String,
    type: json['type'] as String,
    address: json['address'] as String,
    openingHours: json['openingHours'] as String,
    crowdLevel: json['crowdLevel'] as String,
    hasWifi: json['hasWifi'] as bool,
    hasOutlets: json['hasOutlets'] as bool,
    isSilentZone: json['isSilentZone'] as bool,
    rating: (json['rating'] as num).toDouble(),
  );
}
