import 'package:flutter/material.dart';
import 'package:ydental_application/Model/review_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ydental_application/constant.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool isAdd = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(int patientId, int studentId) async {
    _reviews = [];
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$api_local/reviews?patient_id=$patientId&student_id=$studentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _reviews = (data['data'] as List)
            .map((review) => Review.fromJson(review))
            .toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(int patientId, int studentId, String comment, int rating) async {
    try {
      isAdd = true;
      final response = await http.post(
        Uri.parse('$api_local/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': patientId,
          'student_id': studentId,
          'comment': comment,
          'rating': rating,
        }),
      );
      if (response.statusCode == 201) {

        final newReview = Review.fromJson(json.decode(response.body));
        _reviews.insert(0, newReview);
        notifyListeners();
       isAdd = false;
       await fetchReviews(patientId, studentId);

      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      print("Error adding review: $e");
    }
  }
}