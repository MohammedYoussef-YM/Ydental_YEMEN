import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/patint/View/patient_home_screen.dart';
import '../../colors.dart';
import 'patient_appointment_screen.dart';
import 'patient_profile.dart';

class PatientBottomNavigation extends StatefulWidget {
  @override
  State<PatientBottomNavigation> createState() => _PatientBottomNavigationState();
}

class _PatientBottomNavigationState extends State<PatientBottomNavigation> {
  int selectedIndex = 0;
  // late Patient patient; // استخدم late هنا

  @override
  void initState() {
    super.initState();
    }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const PatientHomeScreen(),
      const PatientAppointmentScreen(),
      const PatientProfile(isBack:false), // تمرير patient هنا
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedItemColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home, size: 35),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar_edit,size: 35),
            label: "الحجوزات",
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