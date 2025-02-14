import 'package:flutter/material.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/patint/View/case_detaile.dart';
import '../../../Model/student_model.dart';
import '../../../colors.dart';

class ListOfStudent extends StatelessWidget {
  final MyCasesModel caseStudent;

  const ListOfStudent({super.key, required this.caseStudent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Card(
            shadowColor: Colors.grey,
            surfaceTintColor: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/logo.png', // Fallback image
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        caseStudent.studentName!, // Use caseStudent directly
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 10,),
                      Text(
                        caseStudent.maxAge.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const Text("_", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.primaryColor)),
                      Text(
                        "${caseStudent.minAge}" ,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 5, // Adjust spacing between widgets
                    children: [
                      const SizedBox(width: 10,),
                      Text(
                        "${caseStudent.service.name}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const Text("_", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.primaryColor,
                      )),
                      Text(
                        "${caseStudent.procedure}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the StudentDetaile page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CaseDetaile(student: caseStudent),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        child: const Text("المزيد من التفاصيل"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}