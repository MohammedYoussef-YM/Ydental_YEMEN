import 'package:flutter/material.dart';
import 'package:ydental_application/Model/review_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ydental_application/constant.dart';

class AllReviewForStudentProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool isAdd = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(int studentId) async {
    _reviews = [];
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$api_local/reviews?student_id=$studentId'),
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
      print("Error fetching reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}