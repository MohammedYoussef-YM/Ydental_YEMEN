import 'package:flutter/material.dart';
import 'package:ydental_application/Model/review_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ydental_application/constant.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool isAdd = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore; // Public getter for _hasMore

  // Initial fetch (page 1)
  Future<void> fetchReviews(int studentId) async {
    _currentPage = 1;
    _hasMore = true;
    _reviews = [];
    await _fetchReviewsPage(studentId, page: _currentPage);
  }

  // Private method to fetch a specific page.
  Future<void> _fetchReviewsPage(int studentId, {required int page}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$api_local/reviews?student_id=$studentId&page=$page'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Review> fetchedReviews = (data['data'] as List)
            .map((review) => Review.fromJson(review))
            .toList();
        // If this is a load-more call, append; otherwise replace
        if (page == 1) {
          _reviews = fetchedReviews;
        } else {
          _reviews.addAll(fetchedReviews);
        }

        // Check if there's a next page (using next_page_url from API)
        _hasMore = data['next_page_url'] != null;
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

  // Public method to load more reviews
  Future<void> loadMoreReviews(int studentId) async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _fetchReviewsPage(studentId, page: _currentPage);
  }

  Future<void> addReview(int patientId, int studentId, String comment, int rating) async {
    isAdd = true;
    notifyListeners();

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
      // Optionally, insert at the beginning:
      _reviews.insert(0, newReview);
      isAdd = false;
      notifyListeners();
      // Optionally, refresh reviews from page 1:
      await fetchReviews(studentId);
    } else {
      isAdd = false;
      notifyListeners();
      throw Exception('Failed to add review');
    }
  }
}
