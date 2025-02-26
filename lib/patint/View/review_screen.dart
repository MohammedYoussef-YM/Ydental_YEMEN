import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/patint/View/review_provider.dart';
import 'package:ydental_application/Model/review_model.dart'; // تأكد من استيراد النموذج

class ReviewScreen extends StatefulWidget {
  final int patientId;
  final int studentId;

  ReviewScreen({required this.patientId, required this.studentId});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviews(widget.studentId);
    });

    // Add scroll listener for load more
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<ReviewProvider>(context, listen: false)
            .loadMoreReviews(widget.studentId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final reviews = reviewProvider.reviews;

    double averageRating = reviews.isNotEmpty
        ? reviews.map((review) => review.rating).reduce((a, b) => a + b) / reviews.length
        : 0.0;

    return Scaffold(
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
          // Header with average rating and divider
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RatingBar.builder(
                  initialRating: averageRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 25,
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
          // Reviews List
          reviewProvider.isLoading && reviews.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: reviews.length + 1, // extra item for loader
              itemBuilder: (context, index) {
                if (index < reviews.length) {
                  final review = reviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.patientName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                      }),
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
                } else {
                  // Loader at the bottom
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: reviewProvider.isLoading
                          ? const CircularProgressIndicator()
                          : reviewProvider.hasMore
                          ? const SizedBox.shrink()
                          : const Text('لا يوجد المزيد من التعليقات'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating row for new comment
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Row with submit button and text field
              Row(
                children: [
                  ElevatedButton(
                    onPressed: reviewProvider.isAdd
                        ? null
                        : () {
                      final commentText = _commentController.text;
                      if (commentText.isNotEmpty && _rating > 0) {
                        reviewProvider.addReview(
                          widget.patientId,
                          widget.studentId,
                          commentText,
                          _rating,
                        );
                        _commentController.clear();
                        setState(() {
                          _rating = 0;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: reviewProvider.isAdd
                        ? const CircularProgressIndicator()
                        : const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: ' ...اكتب تعليقًا',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
