import 'package:intl/intl.dart';
import 'patient_model.dart';
import 'cases_model.dart';
import 'student_model.dart';


enum AppointmentStatus { upcoming, confirmed, completed, cancelled }

class Appointment {
  final Patient patient;
  final int appointment_id;
  final DateTime appointment_date;
  final DateTime appointment_time;
  AppointmentStatus status;
  final MyCasesModel case1;
  final int case_id;
  final StudentData? studentData;

  Appointment({
    required this.case1,
    required this.case_id,
    this.studentData,
    required this.status,
    required this.patient,
    required this.appointment_id,
    required this.appointment_date,
    required this.appointment_time,
  });
  // Factory constructor to create an Appointment object from a JSON map
  factory Appointment.fromJson(Map<String, dynamic> json) {


    return Appointment(
      patient: Patient.fromJson(json['appointment']['patient']), // Assuming Patient also has fromJson
      appointment_id: json['appointment_id'],
      appointment_date: DateTime.parse(json['visit_date']),
      appointment_time: DateFormat("HH:mm:ss").parse(json['visit_time']), // Parse the time string
      status: json['status'],
      case1: MyCasesModel.fromJson(json['appointment']['thecase']), // Assuming MyCasesModel has fromJson
      // case1: json['appointment'] != null && json['appointment']['case'] != null ? MyCasesModel.fromJson(json['appointment']['case']) : null, // Assuming MyCasesModel has fromJson
      case_id: json['appointment'] != null ? json['appointment']['case_id'] : 0, // Assuming a case_id field exists
      studentData: json['appointment'] != null && json['appointment']['student'] != null ? StudentData.fromJson(json['appointment']['student']) : null, // Assuming Patient also has fromJson

    );
  }
}

// إزالة البيانات الثابتة
List<Appointment> allAppointment = [];

List<String> tabs = ['بانتظار التأكيد','المؤكدة', 'المكتملة', 'الملغية'];

