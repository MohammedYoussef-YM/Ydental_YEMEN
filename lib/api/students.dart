import 'dart:convert';

import 'package:ydental_application/Model/student_model.dart';
import 'package:http/http.dart' as http;
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/Model/student_model.dart';

class StudentService {

  Future<List<StudentData>> getStudents({
    int? cityId,
    int? universityId,
    String? category,
    int page = 1,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      if (cityId != null) 'city_id': cityId.toString(),
      if (universityId != null) 'university_id': universityId.toString(),
      if (category != null) 'category': category,
    };

    final response = await http.get(
      Uri.parse('$api_local/students').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((student) => StudentData.fromJson(student))
          .toList();
    } else {
      throw Exception('Failed to load students');
    }
  }
}