import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/patint/View/review_provider.dart';
import 'package:ydental_application/Model/review_model.dart';

import 'review_provider.dart'; // تأكد من استيراد النموذج

class AllReviewForStudentScreen extends StatefulWidget {
  final int studentId;

  AllReviewForStudentScreen({required this.studentId});

  @override
  _AllReviewForStudentScreenState createState() => _AllReviewForStudentScreenState();
}

class _AllReviewForStudentScreenState extends State<AllReviewForStudentScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AllReviewForStudentProvider>(context, listen: false)
          .fetchReviews(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<AllReviewForStudentProvider>(context);
    final reviews = reviewProvider.reviews;

    // حساب متوسط التقييم
    double averageRating = reviews.isNotEmpty
        ? reviews.map((review) => review.rating).reduce((a, b) => a + b) / reviews.length
        : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'التعليقات',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            // عرض متوسط التقييم
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${averageRating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: averageRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 30,
                    allowHalfRating: true,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'بناءً على ${reviews.length} تعليق',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Divider(
                    color: Colors.grey[350],
                  ),
                ],
              ),
            ),

            // عرض قائمة التعليقات
            reviewProvider.isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person_2_outlined),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.patientName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        );
                                      }), // Correct closing parenthesis here!
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.comment,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}