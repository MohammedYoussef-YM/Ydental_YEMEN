import 'package:flutter/material.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/colors.dart';

import '../patient_detail.dart';

class ListOfPatient extends StatefulWidget {
  final Patient patient;
  final int student;

  const ListOfPatient({super.key, required this.patient, required this.student});

  @override
  State<ListOfPatient> createState() => _ListOfPatientState();
}

class _ListOfPatientState extends State<ListOfPatient> {
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/patient_image.jpg'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "اسم المريض :${widget.patient.name} ",
                  style: const TextStyle(
                    fontSize: 16,
                    letterSpacing: -.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  ' رقم الهاتف : ${widget.patient.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: grey,
                    letterSpacing: -.5,
                  ),
                ),
                Divider(
                   color: Colors.grey[350],
                 ),

                Row(
                  children: [
                    const Icon(
                      size: 16,
                      Icons.calendar_month,
                      color: grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      " تاريخ الميلاد : ${widget.patient.dateOfBirth}",
                      style: const TextStyle(
                        color: Colors.grey,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      size: 16,
                      Icons.person,
                      color: grey,
                    ),
                    Text(
                      " ${widget.patient.gender}",
                      style: const TextStyle(
                        color: grey,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetail(
                                patient: widget.patient,
                                student: widget.student
                              ),
                            ));
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
                      child: const Text(
                        " تفاصيل المريض ",
                      ),
                    ),
                  ],
                ),

              ]),
            ),
          ),
        ),
      ],
    );
  }
}
