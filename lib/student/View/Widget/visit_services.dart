// visit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ydental_application/Model/visit_model.dart';
import 'package:ydental_application/constant.dart';

class VisitService {

  Future<List<Visit>> getTodayVisits(int studentId) async {
    final response = await http.get(Uri.parse('$api_local/visits/today?student_id=$studentId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الزيارات');
    }
  }

  Future<List<Visit>> getVisits(int studentId) async {
    final response = await http.get(Uri.parse('$api_local/visits/?student_id=$studentId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الزيارات');
    }
  }

  Future<List<Visit>> getPatientsVisits(int patientId) async {
    final response = await http.get(Uri.parse('$api_local/visits/?patient_id=$patientId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الزيارات');
    }
  }

  Future<Visit> updateVisitStatus(Visit visit, VisitStatus newStatus) async {
    final response = await http.put(
      Uri.parse('$api_local/visits/${visit.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': newStatus.toApiString(),
        'visit_time': visit.visitTime,
        'appointment_id': visit.appointmentId,
      }),
    );


    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return Visit.fromJson(jsonData);
      } catch (e) {
        throw Exception('فشل في تحويل البيانات: $e');
      }
    } else {
      throw Exception('فشل في تحديث حالة الزيارة');
    }
  }
}