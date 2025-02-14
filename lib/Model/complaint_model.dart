
import 'patient_model.dart';

class ComplaintModel{

  final int complaint_id;
  final DateTime complaint_date;
  final String complaint_title;
  final String complaint_description;
  final Patient patient_name;

  ComplaintModel({required this.complaint_id, required this.complaint_date, required this.complaint_title, required this.complaint_description, required this.patient_name});



}


