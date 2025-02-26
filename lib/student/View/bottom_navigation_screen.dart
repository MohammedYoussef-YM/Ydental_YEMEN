import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/review_screen.dart';
import 'student_home_screen.dart';
import 'student_profile.dart';

class StudentBottomNavigation extends StatefulWidget {
  const StudentBottomNavigation({super.key});

  @override
  State<StudentBottomNavigation> createState() => _StudentBottomNavigationState();
}

class _StudentBottomNavigationState extends State<StudentBottomNavigation> {
  int selectedIndex = 0;
  StudentData? userData; // Make nullable to handle loading state
  bool isLoading = true;

  final List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  Future<void> _initializeData() async {
    await _loadStudentData();
    setState(() => isLoading = false);
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientJson = prefs.getString('student');

      if (patientJson != null) {
      Map<String, dynamic> patientData = jsonDecode(patientJson);
      setState(() {
        userData = StudentData.fromJson(patientData);
        isLoading = false;

        pages.add(Home(student:userData!));
        pages.add(AllReviewForStudentScreen(studentId: userData!.id!));
        pages.add(StudentProfile(student: userData!, isBack: false));
      });
    } else {
        // Handle case where student is not logged in
        Navigator.pushReplacementNamed(context, '/login');
      }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedItemColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home, size: 35),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.star, size: 35,color: Colors.amber,),
            label: "التقييمات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user, size: 35),
            label: "البيانات الشخصية",
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}