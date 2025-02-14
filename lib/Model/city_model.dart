class City {
  final String id;
  final String name;

  City({required this.id, required this.name});

  // Factory method to create a City object from JSON
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(), // Convert ID to String
      name: json['name'],
    );
  }
}
class University {
  final String id;
  final String name;
  final String cityId;

  University({required this.id, required this.name, required this.cityId});

  // Factory method to create a University object from JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'].toString(), // Convert ID to String
      name: json['name'],
      cityId: json['city_id'].toString(), // Convert city_id to String
    );
  }
}
