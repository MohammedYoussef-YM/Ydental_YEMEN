import 'package:flutter/material.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/student_edit_profile.dart';

class StudentProfile extends StatefulWidget {
  final StudentData student;
  final bool isBack;

  const StudentProfile({super.key, required this.student, required this.isBack});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Center(
            child: Text(
              'البيانات الشخصية',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ),
          leading: widget.isBack == true
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )
          : Container(),// No back button when isBack is false
        ),
        body: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        width: 500,
                        height: 450,
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 7,
                              offset: Offset.zero,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    SizedBox(
                                    width: 80,
                                    height:80,
                                    child: Image.asset('assets/patient_image.jpg', // Fallback image
                                    )),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ' ${widget.student.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(
                                  color: Colors.black12,
                                  indent: 50,
                                  endIndent: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 30, top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildFieldRow(Icons.person, 'اسم المستخدم: ${widget.student.name}'),
                                      buildFieldRow(Icons.phone, 'رقم الهاتف: ${widget.student.phoneNumber}'),
                                      buildFieldRow(Icons.email_outlined, 'الإيميل: ${widget.student.email}'),
                                      buildFieldRow(Icons.person, 'الجنس: ${widget.student.gender}'),
                                      buildFieldRow(Icons.location_city, 'المدينة: ${widget.student.cityName}'),
                                      buildFieldRow(Icons.business, 'الجامعة: ${widget.student.universityName}'),
                                      const SizedBox(height: 10),
                                      buildFieldRow(Icons.school, 'المستوى: ${widget.student.level}'),
                                      buildFieldRow(Icons.card_membership, 'الرقم الأكاديمي: ${widget.student.universityCardNumber}'), // تعديل هنا
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                                onPressed: () {
                                  // Navigate to edit profile if necessary
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const StudentEditProfile()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFieldRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 10), // Space between icon and text
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}