import 'package:flutter/material.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';

class StudentDetail extends StatelessWidget {
  final StudentData student;

  const StudentDetail({super.key, required this.student});

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
              'بيانات الطالب',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor),
          ),
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
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage('assets/patient_image.jpg'),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ' ${student.name}',
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
                                      buildFieldRow(Icons.person, 'اسم الطالب: ${student.name}'),
                                      buildFieldRow(Icons.phone, 'رقم الهاتف: ${student.phoneNumber}'),
                                      buildFieldRow(Icons.email_outlined, 'الإيميل: ${student.email}'),
                                      buildFieldRow( Icons.person, 'الجنس: ${student.gender}'),
                                      buildFieldRow(Icons.location_city, 'المدينة: ${student.cityId}'),
                                      buildFieldRow(Icons.business, 'الجامعة: ${student.universityId}'),
                                      buildFieldRow(Icons.school, 'المستوى: ${student.level}'),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
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