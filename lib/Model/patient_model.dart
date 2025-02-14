
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
// class Patient with ChangeNotifier {
//   int id;
//   String name;
//   String confirmPassword;
//   String password;
//   int phone_number;
//   String email;
//   String gender;
//   DateTime date_of_birth;
//   int? id_Card;
//   String userType;
//   String address;
//  // String profilePicture;
//   String? isBlocked;
//
//   Patient( {required this.id,required this.name,
//     required this.password,required this.confirmPassword, required this.phone_number,
//     required this.email, required this.gender, this.id_Card,required this.userType
//   ,required this.address,required this.date_of_birth,this.isBlocked });
//
// }

List<Patient> allPatient = [
  Patient(
    name: 'ghadeer matuq zaher',
    id: 1,
    email: 'g.mm@gmail.com',
    gender: 'أنثى',
    password: 'gh222222',
    phoneNumber: "77869459",
    idCard: "01002928228",
    dateOfBirth: DateTime(1990, 5, 15),
    confirmPassword: '456',
    userType: 'patient', address: '',
  ),

  Patient(
      name: 'فيصل عبدالرحمن الشريف ',
      email: 'a.mm@gmail.com',
      gender: 'ذكر',
      password: 'gh222222',
      phoneNumber: "77869459",
      id: 3,
      idCard: "01002928228",
      confirmPassword: '', userType: 'patient',
      address: '',
      dateOfBirth: DateTime(1990, 5, 15)

  ),
  Patient(
      name: 'سارة محمد علي',
      email: 's.mm@gmail.com',
      gender: 'أنثى',
      password: 'gh222222',
      phoneNumber: "77869459",
      id: 4,
      idCard: "01002928228",
      confirmPassword: '', userType: 'patient',
      address: '',
      dateOfBirth: DateTime(1990, 5, 15)

  ),
];


