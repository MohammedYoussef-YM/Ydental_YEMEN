import 'package:ydental_application/Model/schedule_model.dart';
import 'package:ydental_application/constant.dart';
import '../api/data.dart';

class MyCasesModel {
  final int id;
  final int studentId;
  final int serviceId;
  final int scheduleId;
  final String description;
  final String procedure;
  final String gender;
  final double cost;
  final List<Schedule> schedule;
  final Service service;
  final String studentName;
  final String studentImage;
  final int minAge;
  final int maxAge;

  MyCasesModel({
    required this.id,
    required this.description,
    required this.procedure,
    required this.gender,
    required this.cost,
    required this.schedule,
    required this.minAge,
    required this.maxAge,
    required this.studentId,
    required this.serviceId,
    required this.scheduleId,
    required this.service,
    required this.studentName,
    required this.studentImage,
  });


// Updated fromJson with full null safety
  factory MyCasesModel.fromJson(Map<String, dynamic> json) {
    // Handle nested objects
    final service = (json['service'] as Map<String, dynamic>?) ?? {};
    // final schedules = (json['schedules'] as Map<String, dynamic>?) ?? {};
    final schedules = (json['schedules'] as List<dynamic>?) ?? []; // List, not Map

    return MyCasesModel(
      id: json['id'] as int? ?? 0,
      studentId: json['student_id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      scheduleId: json['schedules_id'] as int? ?? 0,
      procedure: json['procedure'] as String? ?? 'No Procedure',
      gender: json['gender'] as String? ?? 'Any',
      description: json['description'] as String? ?? 'No Description',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      minAge: json['min_age'] as int? ?? 0,
      maxAge: json['max_age'] as int? ?? 0,
      schedule: schedules.map((s) => Schedule.fromJson(s as Map<String, dynamic>)).toList(),
      service: Service.fromJson(service),
      studentName: json['student']['name']??'',
      studentImage: json['student']['student_image']??'',
    );
  }

  static Future<List<MyCasesModel>> fetchAllCases(int? serviceId) async {
    try {
      final apiService = ApiService(api_local);
      final response ;
      if(serviceId != null){
        response = await apiService.get('/thecases?service_id=$serviceId');
      } else {
        response = await apiService.get('/thecases');
      }

      // Handle null response
      if (response == null) throw Exception('Null API response');

      // Handle error responses
      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      // Safely extract and validate the data list
      final responseData = response['data'];
      if (responseData == null || responseData is! List) {
        return [];
      }

      // Parse cases with error skipping
      return responseData
          .map<MyCasesModel?>((dynamic item) {
        try {
          return MyCasesModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing case: $e - Item: $item');
          return null; // Skip invalid items
        }
      })
          .whereType<MyCasesModel>() // Filter out nulls
          .toList();

    } catch (e) {
      return [];
    }
  }
}

// Add these supporting models
class Service {
  final int id;
  final String name;
  final String icon;

  Service({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int? ?? 0,
      name: json['service_name'] as String? ?? 'Unknown Service',
      icon: json['icon'] as String? ?? '',
    );
  }
}
List<MyCasesModel> myCaseModel = [];
