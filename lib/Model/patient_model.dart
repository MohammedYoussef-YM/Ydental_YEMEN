
import 'package:flutter/cupertino.dart';

class Patient with ChangeNotifier {
  int? id;
  String? name;
  String? email;
  String? password;
  String? confirmPassword;
  String? phoneNumber;
  String? gender;
  DateTime? dateOfBirth;
  String? idCard;
  String? userType;
  String? address;
  String? isBlocked;
  String? createdAt;
  String? updatedAt;

  Patient({
    this.id,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.idCard,
    this.userType,
    this.address,
    this.isBlocked,
    this.createdAt,
    this.updatedAt,
  });

  void updatePatient(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    password = data['password'];
    confirmPassword = data['confirmPassword'];
    phoneNumber = data['phone_number'];
    gender = data['gender'];
    dateOfBirth = DateTime.parse(data['date_of_birth']);
    idCard = data['idCard'];
    userType = data['userType'];
    address = data['address'];
    isBlocked = data['isBlocked'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
    notifyListeners();
  }

  // دالة لتحويل Map إلى كائن Patient
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      phoneNumber: json['phone_number'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      address: json['address'],
      userType: json['userType'],
      isBlocked: "false",
    );
  }
}

List<Patient> allPatient = [];


