import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/login/LoginScreen.dart';
import 'package:ydental_application/login/UserTypeSelectionScreen.dart';
import 'package:ydental_application/patint/View/review_screen.dart';
import 'package:ydental_application/student/View/complaint_screen.dart';
import 'package:ydental_application/student/View/review_screen.dart';
import 'package:ydental_application/student/View/student_setting_screen.dart';
import 'package:ydental_application/student/View/student_profile.dart';

class StudentDrawer extends StatefulWidget {
  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  StudentData? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadStudentData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentJson = prefs.getString('student');

      if (studentJson != null) {
        final studentData = jsonDecode(studentJson) as Map<String, dynamic>;
        setState(() => userData = StudentData.fromJson(studentData));
      }
    } catch (e) {
      print('Error loading student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: EdgeInsets.zero,
          children: _buildMenuItems(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryColor, // لون الخلفية
      padding: const EdgeInsets.all(16), // إضافة بعض المساحة حول المحتوى
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عمودياً
        children: [
          // الصورة
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/logo.png') as ImageProvider,
          ),
          const SizedBox(height: 10), // مسافة بين الصورة والنص
          // الاسم
          Text(
            userData?.name ?? 'مستخدم غير معروف',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white, // لون النص
            ),
          ),
          const SizedBox(height: 5), // مسافة بين الاسم والايميل
          // الإيميل
          Text(
            userData?.email ?? 'الايميل غير معروف',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70, // لون النص
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      _buildHeader(), // Add the header here
      _buildListTile(
        icon: Icons.person,
        title: 'البيانات الشخصية',
        onTap: () => _navigateToProfile(),
        color: primary,
      ),
      _buildListTile(
        icon: Icons.home,
        title: 'الرئيسية',
        onTap: () => Navigator.pop(context),
        color: AppColors.primaryColor,
      ),
      _buildListTile(
        icon: Icons.star,
        title: 'التقييمات',
        onTap: () =>  _navigateToReview(),
        color: Colors.amber,
      ),
      _buildListTile(
        icon: Icons.notifications,
        title: 'الإشعارات',
        onTap: () => Navigator.pop(context),
        color: primary,
      ),
      _buildListTile(
        icon: Icons.report_problem,
        title: 'رفع بلاغ',
        onTap: () =>  _navigateToComplaint(),
        color: AppColors.secondaryColor,
      ),
      _buildListTile(
        icon: Icons.people,
        title: 'من نحن؟',
        onTap: () => Navigator.pop(context),
        color: AppColors.primaryColor,
      ),
      const Divider(
        color: Colors.grey,
        indent: 40,
        thickness: 0.2,
        endIndent: 40,
      ),
      _buildListTile(
        icon: Icons.settings,
        title: 'الإعدادات',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentSettingsScreen())),
        color: AppColors.primaryColor,
      ),
      _buildListTile(
        icon: Icons.logout,
        title: 'تسجيل الخروج',
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserTypeSelection())),
        color: AppColors.primaryColor,
      ),
    ];
  }

  ListTile _buildListTile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      required Color color,
    }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
      );
  }

  void _navigateToProfile() {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentProfile(student: userData!,isBack:true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات متاحة')),
      );
    }
  }

  void _navigateToComplaint() {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Complaint(student: userData!.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات متاحة')),
      );
    }
  }

  void _navigateToReview() {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AllReviewForStudentScreen(studentId: userData!.id!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات متاحة')),
      );
    }
  }
}