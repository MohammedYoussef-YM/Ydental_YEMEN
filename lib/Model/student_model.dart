import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:ydental_application/api/data.dart';
import 'package:ydental_application/city_Provider.dart';
import 'package:ydental_application/constant.dart';
import 'cases_model.dart';
import 'schedule_model.dart';
import 'package:http/http.dart' as http;

class StudentData with ChangeNotifier {
  int? id;
  String? name;
  String? email;
  String? password;
  String? confirmPassword;
  String? level;
  String? gender;
  String? description;
  String? phoneNumber;
  String? universityCardNumber;
  String? universityCardImage;
  String? isBlocked;
  String? cityId;
  String? universityId;
  String? studentImage;
  String? userType;
  final ProfileProvider profileProvider = ProfileProvider();
  Schedule? schedule;
  MyCasesModel? myCaseModel;

  StudentData({
    this.id,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.level,
    this.gender,
    this.description,
    this.phoneNumber,
    this.universityCardNumber,
    this.universityCardImage,
    this.isBlocked,
    this.cityId,
    this.universityId,
    this.studentImage,
    this.userType,
    this.schedule,
    this.myCaseModel,
  });

  void updateStudent(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    password = data['password'];
    confirmPassword = data['confirmPassword'];
    level = data['level'];
    gender = data['gender'];
    description = data['description'];
    phoneNumber = data['phone_number'];
    universityCardNumber = data['university_card_number'];
    universityCardImage = data['university_card_image'];
    isBlocked = data['isBlocked'];
    studentImage = data['student_image'];
    userType = data['userType'];
    cityId = data['city_id'].toString();
    universityId = data['university_id'].toString();
    schedule = data['schedule'] != null ? Schedule.fromJson(data['schedule']) : null;
    myCaseModel = data['my_case_model'] != null ? MyCasesModel.fromJson(data['my_case_model']) : null;

    notifyListeners();
  }

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      level: json['level'],
      gender: json['gender'],
      phoneNumber: json['phone_number'],
      universityCardNumber: json['university_card_number'],
      universityCardImage: json['university_card_image'],
      isBlocked: json['isBlocked'],
      studentImage: json['student_image'],
      userType: json['userType'],
      cityId: json['city_id'].toString(),
      universityId: json['university_id'].toString(),
      myCaseModel: json['my_case_model'] != null ? MyCasesModel.fromJson(json['my_case_model']) : null,
    );
  }

  /// 🚀 Fetch all students from API
  static Future<StudentData> fetchStudentById(int studentId) async {
    final response = await http.get(Uri.parse('$api_local/students/$studentId'));

    if (response.statusCode == 200) {
      return StudentData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load student details');
    }
  }
}

List<StudentData> allStudentData = [];
