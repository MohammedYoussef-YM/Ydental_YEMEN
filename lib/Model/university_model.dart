// class University {
//   final String id;
//   final String name;
//
//   University({required this.id, required this.name});
//
//   // Factory method to create a University object from JSON
//   factory University.fromJson(Map<String, dynamic> json) {
//     return University(
//       id: json['id'],
//       name: json['name'],
//     );
//   }
//
//
//   // Factory method to create a City object from an ID
//   factory University.fromId(int id) {
//     return University(
//       id: id.toString(), // Convert ID to String
//       name: '', // Provide a default name
//     );
//   }
// }