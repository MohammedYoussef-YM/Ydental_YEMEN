import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ydental_application/Model/appointment_model.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/schedule_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/constant.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  Future<void> fetchAppointments() async {
    final String apiUrl = "$api_local/appointments/?patient_id=1&status=مؤكد";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> appointmentsData = jsonResponse["data"];

        _appointments = appointmentsData.map((appointmentJson) {
          return Appointment(
            appointment_id: appointmentJson["id"],
            patient: allPatient.firstWhere(
                    (p) => p.id == appointmentJson["patient_id"],
                ),
            appointment_date:
            DateTime.parse(appointmentJson["created_at"]),
            appointment_time:
            DateTime.parse(appointmentJson["created_at"]),
            status: AppointmentStatus.confirmed, // Adjust logic if needed
            case1: myCaseModel.firstWhere(
                    (c) => c.id == appointmentJson["thecase_id"],
                ),
            studentData: allStudentData.firstWhere(
                    (s) => s.id == appointmentJson["student_id"],
                ), case_id: appointmentJson["thecase_id"],
              schedule: appointmentJson["schedule"]??Schedule(id: 1, isBooking: false, availableDate: DateTime.now(), availableTime: TimeOfDay.now())
          );
        }).toList();

        notifyListeners();
      } else {
        throw Exception("Failed to load appointments");
      }
    } catch (error) {
      print("Error fetching appointments: $error");
    }
  }
}
