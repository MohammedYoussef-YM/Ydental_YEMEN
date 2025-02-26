import 'patient_model.dart';
class Review {
  final int id;
  final int patientId;
  final int rating;
  final String comment;
  final String patientName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int studentId;

  Review({
    required this.id,
    required this.patientId,
    required this.rating,
    required this.comment,
    required this.patientName,
    required this.createdAt,
    required this.updatedAt,
    required this.studentId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      patientId: json['patient_id'],
      rating: json['rating'],
      comment: json['comment'],
      patientName: json['patient'] != null ? json['patient']['name'] : '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      studentId: json['student_id'],
    );
  }
}
// Review
final List<Review> reviews = [];