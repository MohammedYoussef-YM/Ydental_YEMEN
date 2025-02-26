import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/About_us.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/login/LoginScreen.dart';
import 'package:ydental_application/login/UserTypeSelectionScreen.dart';
import 'package:ydental_application/patint/View/complaint_screen.dart';
import 'package:ydental_application/patint/View/patient_profile.dart';
import 'package:ydental_application/patint/View/patient_setting_screen.dart';
import 'package:ydental_application/patint/View/review_screen.dart';
import 'package:ydental_application/patint/View/visit_screen.dart';
import '../../colors.dart';
import '../../student/View/complaint_screen.dart';

class PatientDrawer extends StatefulWidget {
  @override
  State<PatientDrawer> createState() => _PatientDrawerState();
}

class _PatientDrawerState extends State<PatientDrawer> {
  Patient? userData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadPatientData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadPatientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientJson = prefs.getString('patient');
    if (patientJson != null) {
      Map<String, dynamic> patientData = jsonDecode(patientJson);
      setState(() {
        userData = Patient.fromJson(patientData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),

          ListTile(
            leading: const Icon(
              Icons.home,
              color: AppColors.primaryColor,
            ),
            title: const Text('الرئيسية'),
            hoverColor: AppColors.primaryColor,
            onTap: () {
              Navigator.pop(context);
              // ...
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.open_in_browser,
              color: AppColors.secondaryColor,
            ),
            title: const Text('الزيارات'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitPatientScreen(patient:userData!.id!),
                  ));
              // ...
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications,
              color: primary,
            ),
            title: const Text('الإشعارات'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.report_problem,
              color: AppColors.secondaryColor,
            ),
            title: const Text('رفع بلاغ'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintPatient(patient:userData!.id!),
                  ));
              // ...
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.people,
              color: AppColors.primaryColor,
            ),
            title: const Text('من نحن؟'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsScreen(),
                  ));                // ...
            },
          ),
          const Divider(
            color: Colors.grey,
            indent: 40,thickness: 0.2,
            endIndent: 40,
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: AppColors.primaryColor,
            ),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PatientSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: AppColors.primaryColor,
            ),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => UserTypeSelection()),
              );
            },
          ),
        ],
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
}

